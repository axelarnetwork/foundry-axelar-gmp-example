//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@axelar-network/axelar-gmp-sdk-solidity/contracts/executable/AxelarExecutableWithToken.sol";
import "@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGateway.sol";
import "@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGasService.sol";
import "@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IERC20.sol";
import { SafeTokenTransfer, SafeTokenTransferFrom } from "@axelar-network/axelar-gmp-sdk-solidity/contracts/libs/SafeTransfer.sol";

contract DistributionExecutable is AxelarExecutableWithToken {
    using SafeTokenTransfer for IERC20;
    using SafeTokenTransferFrom for IERC20;

    IAxelarGasService public immutable gasService;

    constructor(
        address gateway_,
        address gasReceiver_
    ) AxelarExecutableWithToken(gateway_) {
        gasService = IAxelarGasService(gasReceiver_);
    }

    function sendToMany(
        string memory destinationChain,
        string memory destinationAddress,
        address[] calldata destinationAddresses,
        string memory symbol,
        uint256 amount
    ) external payable {
        require(msg.value > 0, "Gas payment is required");

        address tokenAddress = gatewayWithToken().tokenAddresses(symbol);

        // Check that the sender has enough balance and has allowed the contract to spend the amount.
        require(
            IERC20(tokenAddress).balanceOf(msg.sender) >= amount,
            "Insufficient balance"
        );
        require(
            IERC20(tokenAddress).allowance(msg.sender, address(this)) >= amount,
            "Insufficient allowance"
        );

        IERC20(tokenAddress).safeTransferFrom(msg.sender, address(this), amount);
        IERC20(tokenAddress).approve(address(gatewayWithToken()), amount);
        bytes memory payload = abi.encode(destinationAddresses);
        gasService.payNativeGasForContractCallWithToken{value: msg.value}(
            address(this),
            destinationChain,
            destinationAddress,
            payload,
            symbol,
            amount,
            msg.sender
        );
        gatewayWithToken().callContractWithToken(
            destinationChain,
            destinationAddress,
            payload,
            symbol,
            amount
        );
    }

    function _executeWithToken(
        bytes32 /*commandId*/,
        string calldata,
        string calldata,
        bytes calldata payload,
        string calldata tokenSymbol,
        uint256 amount
    ) internal override {
        // Demo only — this shouldn't be used as-is in production: it does not authenticate the
        // cross-chain message source. Validate sourceChain/sourceAddress against a trusted sender.
        require(amount > 0, "Amount must be greater than 0");
        address[] memory recipients = abi.decode(payload, (address[]));
        require(recipients.length > 0, "Recipients cannot be empty");

        address tokenAddress = gatewayWithToken().tokenAddresses(tokenSymbol);
        require(tokenAddress != address(0), "Invalid token address");

        uint256 sentAmount = amount / recipients.length;
        require(sentAmount > 0, "Sent amount must be greater than 0");

        for (uint256 i = 0; i < recipients.length; i++) {
            require(recipients[i] != address(0), "Invalid recipient address");
            IERC20(tokenAddress).safeTransfer(recipients[i], sentAmount);
        }
    }

    function _execute(
        bytes32 /*commandId*/,
        string calldata /*sourceChain*/,
        string calldata /*sourceAddress*/,
        bytes calldata /*payload*/
    ) internal override {}
}
