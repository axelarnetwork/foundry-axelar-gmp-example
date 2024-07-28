// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "@axelarnetwork/interchain-token-service/contracts/interfaces/IInterchainTokenService.sol";
import "@axelarnetwork/interchain-token-service/contracts/interfaces/ITokenManager.sol";
import "@axelarnetwork/interchain-token-service/contracts/interfaces/ITokenManagerType.sol";
import "../../../src/its-custom-token/CustomToken.sol";

contract CustomTokenScript is Script {
    IInterchainTokenService public sourceIts;
    IInterchainTokenService public destinationIts;
    CustomToken public sourceToken;
    CustomToken public destinationToken;

    uint256 constant WAIT_TIME = 10;
    ITokenManagerType.TokenManagerType constant CUSTOM_MINT_BURN =
        ITokenManagerType.TokenManagerType.MINT_BURN;

    struct DeploymentParams {
        string sourceChain;
        string destinationChain;
        address sourceItsAddress;
        address destinationItsAddress;
        string name;
        string symbol;
        uint8 decimals;
        uint256 amount;
        bytes32 salt;
        address deployer;
    }

    // create emit event
    event SaltValue(bytes32 salt);
    event CustomMintBurn(ITokenManagerType.TokenManagerType mintBurn);
    event SourceIts(IInterchainTokenService sourceIts);

    function run() public {
        deployTokens(getDeploymentParams());
    }

    function validateChain(
        string memory chain
    ) internal pure returns (string memory) {
        bytes32 chainHash = keccak256(abi.encodePacked(toUpperCase(chain)));
        if (
            chainHash == keccak256("ETHEREUM") ||
            chainHash == keccak256("AVALANCHE") ||
            chainHash == keccak256("MOONBEAM") ||
            chainHash == keccak256("FANTOM") ||
            chainHash == keccak256("POLYGON")
        ) {
            return chain;
        }
        revert(string(abi.encodePacked("Invalid chain: ", chain)));
    }

    function toUpperCase(
        string memory str
    ) internal pure returns (string memory) {
        bytes memory bStr = bytes(str);
        bytes memory bUpper = new bytes(bStr.length);
        for (uint i = 0; i < bStr.length; i++) {
            if ((uint8(bStr[i]) >= 97) && (uint8(bStr[i]) <= 122)) {
                bUpper[i] = bytes1(uint8(bStr[i]) - 32);
            } else {
                bUpper[i] = bStr[i];
            }
        }
        return string(bUpper);
    }
    function getDeploymentParams()
        internal
        view
        returns (DeploymentParams memory)
    {
        DeploymentParams memory params;
        params.sourceChain = validateChain(vm.envString("SOURCE_CHAIN"));
        console.log("Source Chain: %s", params.sourceChain);
        params.destinationChain = validateChain(
            vm.envString("DESTINATION_CHAIN")
        );
        console.log("Destination Chain: %s", params.destinationChain);

        string memory sourceChainUpper = toUpperCase(params.sourceChain);
        string memory destChainUpper = toUpperCase(params.destinationChain);
        params.sourceItsAddress = vm.envAddress(
            string(
                abi.encodePacked(
                    "LOCAL_",
                    sourceChainUpper,
                    "_INTERCHAIN_TOKEN_SERVICE"
                )
            )
        );
        params.destinationItsAddress = vm.envAddress(
            string(
                abi.encodePacked(
                    "LOCAL_",
                    destChainUpper,
                    "_INTERCHAIN_TOKEN_SERVICE"
                )
            )
        );
        params.name = vm.envString("TOKEN_NAME");
        params.symbol = vm.envString("TOKEN_SYMBOL");
        params.decimals = uint8(vm.envUint("TOKEN_DECIMALS"));
        params.amount = vm.envUint("TOKEN_AMOUNT");
        params.salt = keccak256(abi.encodePacked(block.timestamp, msg.sender));
        params.deployer = vm.addr(vm.envUint("LOCAL_PRIVATE_KEY"));
        return params;
    }

    function deployTokens(DeploymentParams memory params) internal {
        sourceIts = IInterchainTokenService(params.sourceItsAddress);
        destinationIts = IInterchainTokenService(params.destinationItsAddress);

        // Check if ITS contracts are properly set up
        require(address(sourceIts) != address(0), "Source ITS address is zero");
        require(
            address(destinationIts) != address(0),
            "Destination ITS address is zero"
        );

        vm.startBroadcast(vm.envUint("LOCAL_PRIVATE_KEY"));

        deploySourceToken(params);
        deployDestinationToken(params);
        deployTokenManagers(params);
        performInterchainTransfer(params);

        vm.stopBroadcast();
    }

    function deploySourceToken(DeploymentParams memory params) internal {
        console.log("Deploying CustomToken for source chain");
        sourceToken = new CustomToken(
            params.name,
            params.symbol,
            params.decimals,
            params.sourceItsAddress
        );
        console.log(
            "Deployed CustomToken for source chain at %s",
            address(sourceToken)
        );
    }

    function deployDestinationToken(DeploymentParams memory params) internal {
        console.log("Deploying CustomToken for destination chain");
        destinationToken = new CustomToken(
            params.name,
            params.symbol,
            params.decimals,
            params.destinationItsAddress
        );
        console.log(
            "Deployed CustomToken for destination chain at %s",
            address(destinationToken)
        );
    }

    // function deployTokenManagers(DeploymentParams memory params) internal {
    //     console.log("Registering custom token for source chain");
    //     bytes memory tokenManagerParams = abi.encode(
    //         params.deployer,
    //         address(sourceToken)
    //     );

    //     try
    //         sourceIts.deployTokenManager(
    //             params.salt,
    //             "",
    //             CUSTOM_MINT_BURN,
    //             tokenManagerParams,
    //             0
    //         )
    //     {
    //         console.log("Token manager deployed successfully for source chain");
    //     } catch Error(string memory reason) {
    //         console.log(
    //             "Failed to deploy token manager for source chain: %s",
    //             reason
    //         );
    //         revert(reason);
    //     } catch (bytes memory lowLevelData) {
    //         console.log(
    //             "Low-level error deploying token manager for source chain"
    //         );
    //         revert("Low-level error in source token manager deployment");
    //     }

    //     sourceToken.setItsSalt(params.salt);

    //     bytes32 tokenId = sourceIts.interchainTokenId(
    //         params.deployer,
    //         params.salt
    //     );
    //     address tokenManagerAddress = sourceIts.tokenManagerAddress(tokenId);
    //     console.log("Source Token Manager Address: %s", tokenManagerAddress);

    //     sourceToken.addMinter(tokenManagerAddress);

    //     console.log("Registering custom token for destination chain");
    //     tokenManagerParams = abi.encode(
    //         params.deployer,
    //         address(destinationToken)
    //     );

    //     try
    //         destinationIts.deployTokenManager(
    //             params.salt,
    //             "",
    //             CUSTOM_MINT_BURN,
    //             tokenManagerParams,
    //             0
    //         )
    //     {
    //         console.log(
    //             "Token manager deployed successfully for destination chain"
    //         );
    //     } catch Error(string memory reason) {
    //         console.log(
    //             "Failed to deploy token manager for destination chain: %s",
    //             reason
    //         );
    //         revert(reason);
    //     } catch (bytes memory lowLevelData) {
    //         console.log(
    //             "Low-level error deploying token manager for destination chain"
    //         );
    //         revert("Low-level error in destination token manager deployment");
    //     }

    //     destinationToken.setItsSalt(params.salt);

    //     tokenManagerAddress = destinationIts.tokenManagerAddress(tokenId);
    //     console.log(
    //         "Destination Token Manager Address: %s",
    //         tokenManagerAddress
    //     );

    //     destinationToken.addMinter(tokenManagerAddress);
    // }

    function deployTokenManagers(DeploymentParams memory params) internal {
        console.log("Registering custom token for source chain");
        sourceIts = IInterchainTokenService(params.sourceItsAddress);
        console.log("Deployer: %s", params.deployer);
        console.log("Source Token: %s", address(sourceToken));
        console.log("SOurce ITS Address: %s", params.sourceItsAddress);

        emit SaltValue(params.salt);
        emit CustomMintBurn(CUSTOM_MINT_BURN);
        emit SourceIts(sourceIts);

        bytes memory tokenManagerParams = abi.encode(
            params.deployer,
            address(sourceToken)
        );
        console.log("Registering custom token for source chain 0");

        try
            sourceIts.deployTokenManager(
                params.salt,
                "",
                CUSTOM_MINT_BURN,
                tokenManagerParams,
                0
            )
        {
            console.log("Token manager deployed successfully for source chain");
        } catch Error(string memory reason) {
            console.log(
                "Failed to deploy token manager for source chain: %s",
                reason
            );
            revert(reason);
        } catch (bytes memory lowLevelData) {
            console.logBytes(lowLevelData);
            console.log(
                "Low-level error deploying token manager for source chain"
            );
            revert("Low-level error in source token manager deployment");
        }
        console.log("Registering custom token for source chain 1");
        sourceToken.setItsSalt(params.salt);

        bytes32 tokenId = sourceIts.interchainTokenId(
            params.deployer,
            params.salt
        );
        console.log("Registering custom token for source chain 2");
        address tokenManagerAddress = sourceIts.tokenManagerAddress(tokenId);
        console.log("Registering custom token for source chain 2");
        sourceToken.addMinter(tokenManagerAddress);

        console.log("Registering custom token for destination chain");
        tokenManagerParams = abi.encode(
            params.deployer,
            address(destinationToken)
        );
        destinationIts.deployTokenManager(
            params.salt,
            "",
            CUSTOM_MINT_BURN,
            tokenManagerParams,
            0
        );
        destinationToken.setItsSalt(params.salt);

        tokenManagerAddress = destinationIts.tokenManagerAddress(tokenId);
        destinationToken.addMinter(tokenManagerAddress);
    }

    function performInterchainTransfer(
        DeploymentParams memory params
    ) internal {
        console.log(
            "Minting %s of custom tokens to %s",
            params.amount,
            params.deployer
        );
        sourceToken.mint(params.deployer, params.amount);

        bytes32 tokenId = sourceIts.interchainTokenId(
            params.deployer,
            params.salt
        );
        uint256 fee = 0.001 ether; // This should be calculated or obtained from a gas service

        console.log("Performing interchain transfer");
        sourceIts.interchainTransfer{value: fee}(
            tokenId,
            params.destinationChain,
            abi.encodePacked(params.deployer),
            params.amount,
            "",
            fee
        );

        // In a real scenario, we would need to wait for the transfer to be processed
        vm.warp(block.timestamp + WAIT_TIME);

        uint256 destinationBalance = destinationToken.balanceOf(
            params.deployer
        );
        console.log(
            "Destination chain balance after transfer: %s",
            destinationBalance
        );
    }
}
