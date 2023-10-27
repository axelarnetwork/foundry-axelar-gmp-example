// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import "forge-std/console.sol";


contract ExecutableSample is Script {
    function setUp() public {}

    function run() public {
        vm.broadcast();
    }
}
