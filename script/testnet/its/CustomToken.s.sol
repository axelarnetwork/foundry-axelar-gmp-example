// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "@axelarnetwork/interchain-token-service/contracts/interfaces/IInterchainTokenService.sol";
import "@axelarnetwork/interchain-token-service/contracts/interfaces/IInterchainTokenFactory.sol";
import "@axelarnetwork/interchain-token-service/contracts/interfaces/ITokenManagerType.sol";
import "../../../src/its-custom-token/CustomToken.sol";
import "../../utils/StringUtils.sol";
import "../../utils/InterchainTransferUtils.sol";

contract CustomTokenTestnetScript is Script {
    struct NetworkInfo {
        string name;
        address itsAddress;
        address tokenAddress;
    }

    function deploy() public {
        string memory sourceNetwork = vm.envString("NETWORK");
        string memory destNetwork = vm.envString("DESTINATION_CHAIN");
        uint256 mintAmount = vm.envUint("TOKEN_AMOUNT");

        NetworkInfo memory source = getNetworkInfo(sourceNetwork);
        NetworkInfo memory dest = getNetworkInfo(destNetwork);

        console.log("==== Setup Configuration ====");
        console.log("Source Network: %s", source.name);
        console.log("Destination Network: %s", dest.name);
        console.log("Source ITS Address: %s", source.itsAddress);
        console.log("Destination ITS Address: %s", dest.itsAddress);
        console.log("Mint Amount: %d", mintAmount);
        console.log("=============================");

        vm.startBroadcast(vm.envUint("TESTNET_PRIVATE_KEY"));

        address deployer = vm.addr(vm.envUint("TESTNET_PRIVATE_KEY"));
        console.log("Deployer address: %s", deployer);

        IInterchainTokenService sourceIts = IInterchainTokenService(
            source.itsAddress
        );

        console.log("\n==== Deploying Custom Tokens ====");
        source.tokenAddress = deployCustomToken(source.name, source.itsAddress);
        dest.tokenAddress = deployCustomToken(dest.name, dest.itsAddress);

        bytes32 salt = keccak256(abi.encodePacked(block.timestamp, msg.sender));
        console.log("\nSalt for token deployments: %s", vm.toString(salt));

        console.log("\n==== Deploying Token Managers ====");
        setupTokenManager(source, deployer, salt, false);
        setupTokenManager(dest, deployer, salt, true);

        bytes32 tokenId = sourceIts.interchainTokenId(deployer, salt);
        console.log("\nToken ID: %s", vm.toString(tokenId));

        console.log("\n==== Minting Tokens ====");
        CustomToken(source.tokenAddress).mint(deployer, mintAmount);
        console.log(
            "Minted %d tokens to %s on source chain",
            mintAmount,
            deployer
        );

        uint256 sourceBalance = CustomToken(source.tokenAddress).balanceOf(
            deployer
        );
        console.log("Source chain balance after minting: %d", sourceBalance);

        vm.stopBroadcast();
    }

    function transfer() public {
        string memory sourceNetwork = vm.envString("NETWORK");
        string memory destNetwork = vm.envString("DESTINATION_CHAIN");
        uint256 transferAmount = vm.envUint("TOKEN_AMOUNT");
        address tokenAddress = vm.envAddress("CANONICAL_TOKEN_ADDRESS");
        bytes32 tokenId = bytes32(vm.envBytes32("TOKEN_ID"));

        NetworkInfo memory source = getNetworkInfo(sourceNetwork);

        console.log("==== Transfer Configuration ====");
        console.log("Source Network: %s", source.name);
        console.log("Destination Network: %s", destNetwork);
        console.log("Source ITS Address: %s", source.itsAddress);
        console.log("Token Address: %s", tokenAddress);
        console.log("Token ID: %s", vm.toString(tokenId));
        console.log("Transfer Amount: %d", transferAmount);
        console.log("=============================");

        vm.startBroadcast(vm.envUint("TESTNET_PRIVATE_KEY"));

        address deployer = vm.addr(vm.envUint("TESTNET_PRIVATE_KEY"));
        IInterchainTokenService sourceIts = IInterchainTokenService(
            source.itsAddress
        );

        console.log("\n==== Initiating Interchain Transfer ====");
        InterchainTransferUtils.performInterchainTransfer(
            sourceIts,
            tokenId,
            destNetwork,
            deployer,
            transferAmount
        );

        uint256 sourceFinalBalance = CustomToken(tokenAddress).balanceOf(
            deployer
        );
        console.log("\nSource chain final balance: %d", sourceFinalBalance);

        vm.stopBroadcast();
    }

    function getNetworkInfo(
        string memory network
    ) internal view returns (NetworkInfo memory) {
        address itsAddress = vm.envAddress("TESTNET_INTERCHAIN_TOKEN_SERVICE");
        address tokenAddress = address(0); // Will be set during deployment
        return NetworkInfo(network, itsAddress, tokenAddress);
    }

    function deployCustomToken(
        string memory network,
        address itsAddress
    ) internal returns (address) {
        string memory tokenName = string(
            abi.encodePacked("CustomToken_", network)
        );
        string memory tokenSymbol = string(abi.encodePacked("CT_", network));
        uint8 decimalsValue = 18; // You can adjust this if needed

        CustomToken token = new CustomToken(
            tokenName,
            tokenSymbol,
            decimalsValue,
            itsAddress
        );
        console.log(
            "Deployed CustomToken for %s at %s",
            network,
            address(token)
        );

        // Set the salt for the token
        bytes32 salt = keccak256(abi.encodePacked(block.timestamp, msg.sender));
        token.setItsSalt(salt);
        console.log("Set salt for CustomToken: %s", vm.toString(salt));

        return address(token);
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
        uint256 gasValue = isRemote ? 0.1 ether : 0; // Adjust gas value for testnet
        its.deployTokenManager{value: gasValue}(
            salt,
            isRemote ? StringUtils.toTitleCase(network.name) : "",
            ITokenManagerType.TokenManagerType.MINT_BURN,
            params,
            gasValue
        );

        bytes32 tokenId = its.interchainTokenId(deployer, salt);
        address tokenManagerAddress = its.tokenManagerAddress(tokenId);
        console.log(
            "Token manager deployed at %s for %s",
            tokenManagerAddress,
            network.name
        );

        CustomToken(network.tokenAddress).addMinter(tokenManagerAddress);
        console.log(
            "Added token manager as minter for CustomToken on %s",
            network.name
        );
    }
}
