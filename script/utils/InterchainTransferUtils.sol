// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@axelarnetwork/interchain-token-service/contracts/interfaces/IInterchainTokenService.sol";
import "../utils/StringUtils.sol";
import "forge-std/console.sol";

library InterchainTransferUtils {
    function performInterchainTransfer(
        IInterchainTokenService its,
        bytes32 tokenId,
        string memory destinationChain,
        address recipient,
        uint256 amount
    ) internal {
        console.log("Performing interchain transfer...");
        try
            its.interchainTransfer(
                tokenId,
                StringUtils.toTitleCase(destinationChain),
                abi.encodePacked(recipient),
                amount,
                "",
                0
            )
        {
            console.log("Interchain transfer initiated successfully");
        } catch Error(string memory reason) {
            console.log("Failed to initiate interchain transfer: %s", reason);
            revert(reason);
        } catch (bytes memory lowLevelData) {
            console.logBytes(lowLevelData);
            console.log("Low-level error initiating interchain transfer");
            revert("Low-level error in interchain transfer");
        }
    }
}
