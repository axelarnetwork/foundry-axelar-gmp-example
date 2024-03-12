//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AxelarExecutable} from "@axelar-gmp-sdk-solidity/contracts/executable/AxelarExecutable.sol";
import {IAxelarGateway} from "@axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGateway.sol";
import {IAxelarGasService} from "@axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGasService.sol";
import {IERC20} from "@axelar-gmp-sdk-solidity/contracts/interfaces/IERC20.sol";

contract DistributionExecutable is AxelarExecutable {
    IAxelarGasService public immutable gasService;

    constructor(address gateway_, address gasReceiver_) AxelarExecutable(gateway_) {
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

        address tokenAddress = gateway.tokenAddresses(symbol);

        // Check that the sender has enough balance and has allowed the contract to spend the amount.
        require(IERC20(tokenAddress).balanceOf(msg.sender) >= amount, "Insufficient balance");
        require(IERC20(tokenAddress).allowance(msg.sender, address(this)) >= amount, "Insufficient allowance");
        
        IERC20(tokenAddress).transferFrom(msg.sender, address(this), amount);
        IERC20(tokenAddress).approve(address(gateway), amount);
        bytes memory payload = abi.encode(destinationAddresses);
        gasService.payNativeGasForContractCallWithToken{value: msg.value}(
            address(this), destinationChain, destinationAddress, payload, symbol, amount, msg.sender
        );
        gateway.callContractWithToken(destinationChain, destinationAddress, payload, symbol, amount);
    }

    function _executeWithToken(
        string calldata sourceChain,
        string calldata sourceAddress,
        bytes calldata payload,
        string calldata tokenSymbol,
        uint256 amount
    ) internal override {
        require(amount > 0, "Amount must be greater than 0");
        address[] memory recipients = abi.decode(payload, (address[]));
        require(recipients.length > 0, "Recipients cannot be empty");

        address tokenAddress = gateway.tokenAddresses(tokenSymbol);
        require(tokenAddress != address(0), "Invalid token address");

        uint256 sentAmount = amount / recipients.length;
        require(sentAmount > 0, "Sent amount must be greater than 0");

        for (uint256 i = 0; i < recipients.length; i++) {
            require(recipients[i] != address(0), "Invalid recipient address");
            IERC20(tokenAddress).transfer(recipients[i], sentAmount);
        }
    }

}
