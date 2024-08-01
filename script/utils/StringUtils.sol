// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "forge-std/Script.sol";
import "@axelarnetwork/interchain-token-service/contracts/interfaces/IInterchainTokenService.sol";

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

    function setTrustedAddress(
        IInterchainTokenService its,
        string memory chain,
        string memory address_
    ) internal {
        console.log("Setting trusted address for %s: %s", chain, address_);
        try its.setTrustedAddress(chain, address_) {
            console.log("Successfully set trusted address for %s", chain);
        } catch Error(string memory reason) {
            console.log("Failed to set trusted address: %s", reason);
        } catch (bytes memory lowLevelData) {
            console.logBytes(lowLevelData);
            console.log("Low-level error setting trusted address");
        }
    }

    function addressToString(
        address _addr
    ) internal pure returns (string memory) {
        bytes32 value = bytes32(uint256(uint160(_addr)));
        bytes memory alphabet = "0123456789abcdef";

        bytes memory str = new bytes(42);
        str[0] = "0";
        str[1] = "x";
        for (uint i = 0; i < 20; i++) {
            str[2 + i * 2] = alphabet[uint(uint8(value[i + 12] >> 4))];
            str[3 + i * 2] = alphabet[uint(uint8(value[i + 12] & 0x0f))];
        }
        return string(str);
    }
}
