// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "@axelarnetwork/interchain-token-service/contracts/interfaces/IInterchainTokenService.sol";
import "@axelarnetwork/interchain-token-service/contracts/interfaces/ITokenManagerType.sol";
import "../../../src/its-custom-token/CustomToken.sol";
import "../../utils/StringUtils.sol";

contract SetupTokenManagersScript is Script {
    struct NetworkInfo {
        string name;
        address itsAddress;
        address tokenAddress;
    }

    function run() public {
        NetworkInfo memory source = getNetworkInfo("SOURCE");
        NetworkInfo memory dest = getNetworkInfo("DEST");
        uint256 mintAmount = vm.envUint("MINT_AMOUNT");
        uint256 transferAmount = vm.envUint("TRANSFER_AMOUNT");

        console.log("==== Setup Configuration ====");
        console.log("Source Network: %s", source.name);
        console.log("Destination Network: %s", dest.name);
        console.log("Source ITS Address: %s", source.itsAddress);
        console.log("Destination ITS Address: %s", dest.itsAddress);
        console.log("Source Token Address: %s", source.tokenAddress);
        console.log("Destination Token Address: %s", dest.tokenAddress);
        console.log("Mint Amount: %d", mintAmount);
        console.log("Transfer Amount: %d", transferAmount);
        console.log("=============================");

        vm.startBroadcast(vm.envUint("LOCAL_PRIVATE_KEY"));

        address deployer = vm.addr(vm.envUint("LOCAL_PRIVATE_KEY"));
        console.log("Deployer address: %s", deployer);

        IInterchainTokenService sourceIts = IInterchainTokenService(
            source.itsAddress
        );
        IInterchainTokenService destIts = IInterchainTokenService(
            dest.itsAddress
        );

        console.log("\n==== Setting Trusted Addresses ====");
        setupTrustedAddresses(sourceIts, destIts, source, dest);

        bytes32 salt = keccak256(abi.encodePacked(block.timestamp, msg.sender));
        console.log("\nSalt for token deployments: %s", vm.toString(salt));

        console.log("\n==== Deploying Token Managers ====");
        setupTokenManager(source, deployer, salt, false);
        setupTokenManager(dest, deployer, salt, true);

        bytes32 tokenId = sourceIts.interchainTokenId(deployer, salt);
        console.log("\nToken ID: %s", vm.toString(tokenId));

        console.log("\n==== Initial Balances ====");
        uint256 sourceInitialBalance = CustomToken(source.tokenAddress)
            .balanceOf(deployer);
        uint256 destInitialBalance = CustomToken(dest.tokenAddress).balanceOf(
            deployer
        );
        console.log("Source chain initial balance: %d", sourceInitialBalance);
        console.log(
            "Destination chain initial balance: %d",
            destInitialBalance
        );

        console.log("\n==== Minting Tokens ====");
        CustomToken(source.tokenAddress).mint(deployer, mintAmount);
        console.log(
            "Minted %d tokens to %s on source chain",
            mintAmount,
            deployer
        );

        uint256 sourceAfterMintBalance = CustomToken(source.tokenAddress)
            .balanceOf(deployer);
        console.log(
            "Source chain balance after minting: %d",
            sourceAfterMintBalance
        );

        console.log("\n==== Initiating Interchain Transfer ====");
        performInterchainTransfer(
            sourceIts,
            tokenId,
            dest.name,
            deployer,
            transferAmount
        );

        console.log("\n==== Final Balances ====");
        uint256 sourceFinalBalance = CustomToken(source.tokenAddress).balanceOf(
            deployer
        );
        uint256 destFinalBalance = CustomToken(dest.tokenAddress).balanceOf(
            deployer
        );
        console.log("Source chain final balance: %d", sourceFinalBalance);
        console.log("Destination chain final balance: %d", destFinalBalance);
        console.log(
            "Note: The destination chain balance may not reflect the transfer immediately due to the nature of cross-chain transactions."
        );

        console.log("\n==== Transfer Summary ====");
        console.log("Tokens minted on source chain: %d", mintAmount);
        console.log(
            "Tokens transferred to destination chain: %d",
            transferAmount
        );
        console.log(
            "Change in source chain balance: %d",
            sourceFinalBalance - sourceInitialBalance
        );

        vm.stopBroadcast();
    }

    function getNetworkInfo(
        string memory prefix
    ) internal view returns (NetworkInfo memory) {
        string memory network = vm.envString(
            string(abi.encodePacked(prefix, "_NETWORK"))
        );
        string memory upperNetwork = StringUtils.toUpperCase(network);
        address itsAddress = vm.envAddress(
            string(
                abi.encodePacked(
                    "LOCAL_",
                    upperNetwork,
                    "_INTERCHAIN_TOKEN_SERVICE"
                )
            )
        );
        address tokenAddress = vm.envAddress(
            string(
                abi.encodePacked(
                    "LOCAL_",
                    upperNetwork,
                    "_CUSTOMTOKEN_CONTRACT_ADDRESS"
                )
            )
        );
        return NetworkInfo(network, itsAddress, tokenAddress);
    }

    function setupTrustedAddresses(
        IInterchainTokenService sourceIts,
        IInterchainTokenService destIts,
        NetworkInfo memory source,
        NetworkInfo memory dest
    ) internal {
        if (sourceIts.owner() == msg.sender) {
            console.log(
                "Setting trusted address for %s on %s",
                dest.name,
                source.name
            );
            StringUtils.setTrustedAddress(
                sourceIts,
                dest.name,
                StringUtils.addressToString(dest.itsAddress)
            );
        } else {
            console.log(
                "Warning: Not owner of source ITS, skipping setTrustedAddress"
            );
        }

        if (destIts.owner() == msg.sender) {
            console.log(
                "Setting trusted address for %s on %s",
                source.name,
                dest.name
            );
            StringUtils.setTrustedAddress(
                destIts,
                source.name,
                StringUtils.addressToString(source.itsAddress)
            );
        } else {
            console.log(
                "Warning: Not owner of destination ITS, skipping setTrustedAddress"
            );
        }
    }

    function setupTokenManager(
        NetworkInfo memory network,
        address deployer,
        bytes32 salt,
        bool isRemote
    ) internal {
        bytes memory params = abi.encode(
            abi.encodePacked(deployer),
            network.tokenAddress
        );

        IInterchainTokenService its = IInterchainTokenService(
            network.itsAddress
        );
        deployTokenManager(its, salt, params, network.name, isRemote);

        // Get the token manager address
        bytes32 tokenId = its.interchainTokenId(deployer, salt);
        address tokenManagerAddress = its.tokenManagerAddress(tokenId);

        // Add the token manager as a minter to the CustomToken
        try CustomToken(network.tokenAddress).addMinter(tokenManagerAddress) {
            console.log(
                "Added token manager %s as minter for CustomToken on %s",
                tokenManagerAddress,
                network.name
            );
        } catch Error(string memory reason) {
            console.log("Failed to add token manager as minter: %s", reason);
        }
    }

    function deployTokenManager(
        IInterchainTokenService its,
        bytes32 salt,
        bytes memory params,
        string memory network,
        bool isRemote
    ) internal {
        console.log("Deploying token manager for %s network...", network);
        uint256 gasValue = isRemote ? 1 ether : 0;
        try
            its.deployTokenManager{value: gasValue}(
                salt,
                isRemote ? StringUtils.toTitleCase(network) : "",
                ITokenManagerType.TokenManagerType.MINT_BURN,
                params,
                isRemote ? 1 ether : 0
            )
        {
            console.log(
                "Token manager deployed successfully for %s network",
                network
            );
        } catch Error(string memory reason) {
            console.log(
                "Failed to deploy token manager for %s network: %s",
                network,
                reason
            );
        } catch (bytes memory lowLevelData) {
            console.logBytes(lowLevelData);
            console.log(
                "Low-level error deploying token manager for %s network",
                network
            );

            // Try to decode the error if possible
            (bool success, bytes memory result) = address(its).staticcall(
                abi.encodeWithSignature(
                    "TokenManagerDeploymentFailed(bytes)",
                    lowLevelData
                )
            );
            if (success) {
                console.logBytes(result);
                console.log("Decoded TokenManagerDeploymentFailed error");
            } else {
                console.log("Unable to decode error data");
            }
        }
    }

    function performInterchainTransfer(
        IInterchainTokenService its,
        bytes32 tokenId,
        string memory destinationChain,
        address recipient,
        uint256 amount
    ) internal {
        console.log("Performing interchain transfer...");
        try
            its.interchainTransfer(
                tokenId,
                StringUtils.toTitleCase(destinationChain),
                abi.encodePacked(recipient),
                amount,
                "",
                0
            )
        {
            console.log("Interchain transfer initiated successfully");
        } catch Error(string memory reason) {
            console.log("Failed to initiate interchain transfer: %s", reason);
            revert(reason);
        } catch (bytes memory lowLevelData) {
            console.logBytes(lowLevelData);
            console.log("Low-level error initiating interchain transfer");
            revert("Low-level error in interchain transfer");
        }
    }
}
