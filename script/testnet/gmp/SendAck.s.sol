// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../../../src/send-ack/SendAck.sol";
import "../../testnet/NetworkDetailsBase.sol";

contract SendAckScript is Script, NetworkDetailsBase {
    ExecutableSample public executableSample;

    function run() public {
        uint256 privateKey = vm.envUint("TESTNET_PRIVATE_KEY");
        string memory network = vm.envString("NETWORK");

        (address gateway, address gasService) = getNetworkDetails(network);

        vm.startBroadcast(privateKey);
        executableSample = new ExecutableSample(gateway, gasService);
        vm.stopBroadcast();
    }
}
