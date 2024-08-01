// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library StringUtils {
    function toUpperCase(
        string memory _base
    ) internal pure returns (string memory) {
        bytes memory bStr = bytes(_base);
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

    function toTitleCase(
        string memory str
    ) internal pure returns (string memory) {
        bytes memory bStr = bytes(str);
        bytes memory bLower = new bytes(bStr.length);
        for (uint i = 0; i < bStr.length; i++) {
            if ((uint8(bStr[i]) >= 65) && (uint8(bStr[i]) <= 90)) {
                bLower[i] = bytes1(uint8(bStr[i]) + 32);
            } else {
                bLower[i] = bStr[i];
            }
        }
        if (bLower.length > 0) {
            bLower[0] = bytes1(uint8(bLower[0]) - 32);
        }
        return string(bLower);
    }
}
