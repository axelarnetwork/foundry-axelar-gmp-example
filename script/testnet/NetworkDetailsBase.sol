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
        networkDetails["ethereum"] = NetworkDetails(vm.envAddress("ETHEREUM_GATEWAY_ADDRESS"), vm.envAddress("ETHEREUM_GAS_SERVICE_ADDRESS"));
        networkDetails["avalanche"] = NetworkDetails(vm.envAddress("AVALANCHE_GATEWAY_ADDRESS"), vm.envAddress("AVALANCHE_GAS_SERVICE_ADDRESS"));
        networkDetails["moonbeam"] = NetworkDetails(vm.envAddress("MOONBEAM_GATEWAY_ADDRESS"), vm.envAddress("MOONBEAM_GAS_SERVICE_ADDRESS"));
        networkDetails["fantom"] = NetworkDetails(vm.envAddress("FANTOM_GATEWAY_ADDRESS"), vm.envAddress("FANTOM_GAS_SERVICE_ADDRESS"));
        networkDetails["polygon"] = NetworkDetails(vm.envAddress("POLYGON_GATEWAY_ADDRESS"), vm.envAddress("POLYGON_GAS_SERVICE_ADDRESS"));
    }

    function getNetworkDetails(string memory network) internal view returns (address gateway, address gasService) {
        require(networkDetails[network].gateway != address(0), "Invalid network");

        NetworkDetails memory details = networkDetails[network];
        return (details.gateway, details.gasService);
    }
}
