// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "@axelarnetwork/interchain-token-service/contracts/interfaces/IInterchainTokenService.sol";
import "@axelarnetwork/interchain-token-service/contracts/interfaces/ITokenManagerType.sol";
import "../../../src/its-custom-token/CustomToken.sol";

contract SetupTokenManagersScript is Script {
    event tokenManagerParamsEvent(bytes tokenManagerParams);

    function run() public {
        string memory sourceNetwork = vm.envString("SOURCE_NETWORK");
        string memory destNetwork = vm.envString("DEST_NETWORK");
        address sourceToken = vm.envAddress("SOURCE_TOKEN");
        address destToken = vm.envAddress("DEST_TOKEN");

        string memory sourceNetworkUpper = toUpperCase(sourceNetwork);
        string memory destNetworkUpper = toUpperCase(destNetwork);

        address sourceItsAddress = vm.envAddress(
            string(
                abi.encodePacked(
                    "LOCAL_",
                    sourceNetworkUpper,
                    "_INTERCHAIN_TOKEN_SERVICE"
                )
            )
        );
        address destItsAddress = vm.envAddress(
            string(
                abi.encodePacked(
                    "LOCAL_",
                    destNetworkUpper,
                    "_INTERCHAIN_TOKEN_SERVICE"
                )
            )
        );

        console.log("Source ITS Address: %s", sourceItsAddress);
        console.log("Destination ITS Address: %s", destItsAddress);
        console.log("Source Token Address: %s", sourceToken);
        console.log("Destination Token Address: %s", destToken);

        vm.startBroadcast(vm.envUint("LOCAL_PRIVATE_KEY"));

        IInterchainTokenService sourceIts = IInterchainTokenService(
            sourceItsAddress
        );
        // IInterchainTokenService destIts = IInterchainTokenService(
        //     destItsAddress
        // );

        bytes32 salt = keccak256(abi.encodePacked(block.timestamp, msg.sender));
        address deployer = vm.addr(vm.envUint("LOCAL_PRIVATE_KEY"));

        console.log("Deployer address: %s", deployer);
        console.log("Salt: %s", vm.toString(salt));

        bytes memory tokenManagerParams = abi.encode(deployer, sourceToken);

        emit tokenManagerParamsEvent(tokenManagerParams);

        console.log("Deploying token manager for source network...");
        try
            sourceIts.deployTokenManager(
                salt,
                "",
                ITokenManagerType.TokenManagerType.MINT_BURN,
                tokenManagerParams,
                0
            )
        {
            console.log(
                "Token manager deployed successfully for source network"
            );
        } catch Error(string memory reason) {
            console.log(
                "Failed to deploy token manager for source network: %s",
                reason
            );
            revert(reason);
        } catch (bytes memory lowLevelData) {
            console.logBytes(lowLevelData);
            console.log(
                "Low-level error deploying token manager for source network"
            );
            revert("Low-level error in source token manager deployment");
        }
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
}
