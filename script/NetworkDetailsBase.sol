// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";

contract NetworkDetailsBase is Script {
    function getNetworkDetails(string memory network) internal view returns (address gateway, address gasService) {
        if (keccak256(abi.encodePacked(network)) == keccak256(abi.encodePacked("polygon"))) {
            return (vm.envAddress("POLYGON_GATEWAY"), vm.envAddress("POLYGON_GAS_SERVICE"));
        }
        if (keccak256(abi.encodePacked(network)) == keccak256(abi.encodePacked("avalanche"))) {
            return (vm.envAddress("AVALANCHE_GATEWAY"), vm.envAddress("AVALANCHE_GAS_SERVICE"));
        }
        if (keccak256(abi.encodePacked(network)) == keccak256(abi.encodePacked("binance"))) {
            return (vm.envAddress("BINANCE_GATEWAY"), vm.envAddress("BINANCE_GAS_SERVICE"));
        }
        if (keccak256(abi.encodePacked(network)) == keccak256(abi.encodePacked("scroll_sepolia"))) {
            return (vm.envAddress("SCROLL_SEPOLIA_GATEWAY"), vm.envAddress("SCROLL_SEPOLIA_GAS_SERVICE"));
        }
        if (keccak256(abi.encodePacked(network)) == keccak256(abi.encodePacked("base"))) {
            return (vm.envAddress("BASE_GATEWAY"), vm.envAddress("BASE_GAS_SERVICE"));
        }
        revert("Invalid network");
    }
}
