// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Test, console2} from "forge-std/Test.sol";
import {ExecutableSample} from "../src/call-contract/ExecutableSample.sol";

contract ExecutableSampleTest is Test {
    ExecutableSample public executableSample;
    address constant POLYGON_GATEWAY = 0xBF62ef1486468a6bd26Dd669C06db43dEd5B849B;
    address constant POLYGON_GAS_SERVICE = 0xbE406F0189A0B4cf3A05C286473D23791Dd44Cc6;

    function setUp() public {
        executableSample = new ExecutableSample(POLYGON_GATEWAY, POLYGON_GAS_SERVICE);
    }

    function test_SetRemoteValue() public {
        executableSample.setRemoteValue{value: 0.5 ether}("destinationChain", "destinationAddress", "value");
        // assertEq(executableSample.value(), "value");
        // assertEq(executableSample.sourceChain(), "destinationChain");
        // assertEq(executableSample.sourceAddress(), "destinationAddress");
    }
}
