// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";

contract NetworkDetailsBase is Script {
    struct NetworkDetails {
        address gateway;
        address gasService;
    }

    mapping(string => NetworkDetails) private networkDetails;

    constructor() {
        // Initialize network details
        networkDetails["ethereum"] = NetworkDetails(vm.envAddress("LOCAL_ETHEREUM_GATEWAY_ADDRESS"), vm.envAddress("LOCAL_ETHEREUM_GATEWAY_ADDRESS"));
        networkDetails["avalanche"] = NetworkDetails(vm.envAddress("LOCAL_AVALANCHE_GATEWAY_ADDRESS"), vm.envAddress("LOCAL_AVALANCHE_GAS_RECEIVER_ADDRESS"));
        networkDetails["moonbeam"] = NetworkDetails(vm.envAddress("LOCAL_MOONBEAM_GATEWAY_ADDRESS"), vm.envAddress("LOCAL_MOONBEAM_GAS_RECEIVER_ADDRESS"));
        networkDetails["fantom"] = NetworkDetails(vm.envAddress("LOCAL_FANTOM_GATEWAY_ADDRESS"), vm.envAddress("LOCAL_FANTOM_GAS_RECEIVER_ADDRESS"));
        networkDetails["polygon"] = NetworkDetails(vm.envAddress("LOCAL_POLYGON_GATEWAY_ADDRESS"), vm.envAddress("LOCAL_POLYGON_GAS_RECEIVER_ADDRESS"));
        
    }

    function getNetworkDetails(string memory network) internal view returns (address gateway, address gasService) {
        require(networkDetails[network].gateway != address(0), "Invalid network");

        NetworkDetails memory details = networkDetails[network];
        return (details.gateway, details.gasService);
    }
}