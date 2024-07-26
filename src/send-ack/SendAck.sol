// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@axelar-gmp-sdk-solidity/contracts/executable/AxelarExecutable.sol";
import "@axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGateway.sol";
import "@axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGasService.sol";
import "@axelar-gmp-sdk-solidity/contracts/interfaces/IERC20.sol";

contract ExecutableSample is AxelarExecutable {
    string public message;
    IAxelarGasService public immutable gasService;

    constructor(
        address gateway_,
        address gasReceiver_
    ) AxelarExecutable(gateway_) {
        gasService = IAxelarGasService(gasReceiver_);
    }

    // Call this function to update the value of this contract along with all its siblings'.
    function sendMessage(
        string calldata destinationChain,
        string calldata destinationAddress,
        string calldata value_
    ) external payable {
        require(msg.value > 0, "Gas payment is required");

        bytes memory payload = abi.encode(value_);
        gasService.payNativeGasForContractCall{value: msg.value}(
            address(this),
            destinationChain,
            destinationAddress,
            payload,
            msg.sender
        );
        gateway.callContract(destinationChain, destinationAddress, payload);
    }

    // Handles calls created by setAndSend. Updates this contract's value
    function _execute(
        string calldata sourceChain_,
        string calldata sourceAddress_,
        bytes calldata payload_
    ) internal override {
        // Decode the payload to retrieve the new message value
        (message) = abi.decode(payload_, (string));

        // Check if the new message is "Hello", then respond with "World"
        if (keccak256(abi.encode(message)) == keccak256(abi.encode("Hello"))) {
            gateway.callContract(
                sourceChain_,
                sourceAddress_,
                abi.encode("World")
            );
        }
    }
}
