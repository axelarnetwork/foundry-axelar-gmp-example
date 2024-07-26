// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "@axelarnetwork/interchain-token-service/contracts/interfaces/IInterchainTokenService.sol";
import "@axelarnetwork/interchain-token-service/contracts/interfaces/IInterchainTokenFactory.sol";

contract InterchainTokenScript is Script {
    IInterchainTokenService public sourceIts;
    IInterchainTokenFactory public sourceFactory;

    event Log(
        string message,
        string param1,
        string param2,
        uint256 param3,
        string param4
    );
    event LogTokenId(string message, bytes32 tokenId);

    function run() public {
        string memory sourceChain = vm.envString("NETWORK");
        address sourceItsAddress = vm.envAddress(
            string(
                abi.encodePacked(
                    "LOCAL_",
                    sourceChain,
                    "_INTERCHAIN_TOKEN_SERVICE"
                )
            )
        );
        address sourceFactoryAddress = vm.envAddress(
            string(
                abi.encodePacked(
                    "LOCAL_",
                    sourceChain,
                    "_INTERCHAIN_TOKEN_FACTORY"
                )
            )
        );

        string memory name = vm.envString("TOKEN_NAME");
        string memory symbol = vm.envString("TOKEN_SYMBOL");
        uint8 decimals = uint8(vm.envUint("TOKEN_DECIMALS"));
        uint256 amount = vm.envUint("TOKEN_AMOUNT");

        bytes32 salt = keccak256(abi.encodePacked(block.timestamp, msg.sender));

        sourceIts = IInterchainTokenService(sourceItsAddress);
        sourceFactory = IInterchainTokenFactory(sourceFactoryAddress);

        uint256 privateKey = vm.envUint("LOCAL_PRIVATE_KEY");
        address deployer = vm.addr(privateKey);

        vm.startBroadcast(privateKey);

        emit Log(
            "Deploying interchain token",
            name,
            symbol,
            decimals,
            sourceChain
        );

        sourceFactory.deployInterchainToken(
            salt,
            name,
            symbol,
            decimals,
            amount,
            deployer
        );

        bytes32 tokenId = sourceFactory.interchainTokenId(deployer, salt);
        emit LogTokenId("Deployed token ID", tokenId);

        vm.stopBroadcast();
    }
}
