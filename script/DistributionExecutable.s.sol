// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/call-contract-with-token/DistributionExecutable.sol";
import "./NetworkDetailsBase.sol";

contract DistributionExecutableScript is Script, NetworkDetailsBase {
    DistributionExecutable public distributionExecutable;

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        string memory network = vm.envString("NETWORK");

        (address gateway, address gasService) = getNetworkDetails(network);

        vm.startBroadcast(privateKey);
        distributionExecutable = new DistributionExecutable(gateway, gasService);
        vm.stopBroadcast();
    }
}
