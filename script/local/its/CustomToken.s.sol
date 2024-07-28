// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "@axelarnetwork/interchain-token-service/contracts/interfaces/IInterchainTokenService.sol";
import "../../../src/its-custom-token/CustomToken.sol";

contract CustomTokenScript is Script {
    function run() public {
        string memory network = vm.envString("NETWORK");
        string memory networkUpper = toUpperCase(network);
        address itsAddress = vm.envAddress(
            string(
                abi.encodePacked(
                    "LOCAL_",
                    networkUpper,
                    "_INTERCHAIN_TOKEN_SERVICE"
                )
            )
        );
        string memory name = vm.envString("TOKEN_NAME");
        string memory symbol = vm.envString("TOKEN_SYMBOL");
        uint8 decimals = uint8(vm.envUint("TOKEN_DECIMALS"));
        uint256 amount = vm.envUint("TOKEN_AMOUNT");

        vm.startBroadcast(vm.envUint("LOCAL_PRIVATE_KEY"));

        CustomToken token = new CustomToken(name, symbol, decimals, itsAddress);

        console.log(
            "Deployed CustomToken for %s at %s",
            network,
            address(token)
        );

        vm.stopBroadcast();
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
