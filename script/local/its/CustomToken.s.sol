// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "@axelarnetwork/interchain-token-service/contracts/interfaces/IInterchainTokenService.sol";
import "../../../src/its-custom-token/CustomToken.sol";
import "../../utils/StringUtils.sol";

contract CustomTokenScript is Script {
    function run() public {
        string memory network = vm.envString("NETWORK");
        string memory networkUpper = StringUtils.toUpperCase(network);
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

        vm.startBroadcast(vm.envUint("LOCAL_PRIVATE_KEY"));

        CustomToken token = new CustomToken(name, symbol, decimals, itsAddress);

        console.log(
            "Deployed CustomToken for %s at %s",
            network,
            address(token)
        );

        vm.stopBroadcast();
    }
}
