// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "@axelarnetwork/interchain-token-service/contracts/interfaces/IInterchainTokenService.sol";
import "@axelarnetwork/interchain-token-service/contracts/interfaces/IInterchainTokenFactory.sol";
import "@axelarnetwork/interchain-token-service/contracts/interfaces/IInterchainToken.sol";
import "../../utils/StringUtils.sol";

contract InterchainTokenTestnetScript is Script {
    IInterchainTokenService public sourceIts;
    IInterchainTokenFactory public sourceFactory;

    uint256 constant FEE = 0.01 ether; // Adjust as needed for testnet

    struct DeploymentParams {
        string sourceChain;
        string destinationChain;
        address sourceItsAddress;
        address sourceFactoryAddress;
        string name;
        string symbol;
        uint8 decimals;
        uint256 amount;
        bytes32 salt;
        address deployer;
    }

    struct TransferParams {
        string sourceChain;
        string destinationChain;
        address sourceItsAddress;
        bytes32 tokenId;
        uint256 amount;
        address deployer;
    }

    function deploy() public {
        DeploymentParams memory params = getDeploymentParams();
        deployAndRegister(params);
    }

    function transfer() public {
        TransferParams memory params = getTransferParams();
        performInterchainTransfer(params);
    }

    function getDeploymentParams()
        internal
        view
        returns (DeploymentParams memory)
    {
        DeploymentParams memory params;
        params.sourceChain = vm.envString("NETWORK");
        params.destinationChain = vm.envString("DESTINATION_CHAIN");
        params.sourceItsAddress = vm.envAddress(
            "TESTNET_INTERCHAIN_TOKEN_SERVICE"
        );
        params.sourceFactoryAddress = vm.envAddress(
            "TESTNET_INTERCHAIN_TOKEN_FACTORY"
        );
        params.name = vm.envString("TOKEN_NAME");
        params.symbol = vm.envString("TOKEN_SYMBOL");
        params.decimals = uint8(vm.envUint("TOKEN_DECIMALS"));
        params.amount = vm.envUint("TOKEN_AMOUNT") * 10 ** params.decimals;
        params.salt = keccak256(abi.encodePacked(block.timestamp, msg.sender));
        params.deployer = vm.addr(vm.envUint("TESTNET_PRIVATE_KEY"));
        return params;
    }

    function getTransferParams() internal view returns (TransferParams memory) {
        TransferParams memory params;
        params.sourceChain = vm.envString("NETWORK");
        params.destinationChain = vm.envString("DESTINATION_CHAIN");
        params.sourceItsAddress = vm.envAddress(
            "TESTNET_INTERCHAIN_TOKEN_SERVICE"
        );
        params.tokenId = bytes32(vm.envBytes32("TOKEN_ID"));
        params.amount = vm.envUint("TOKEN_AMOUNT") * 10 ** 18; // Assuming 18 decimals, adjust if needed
        params.deployer = vm.addr(vm.envUint("TESTNET_PRIVATE_KEY"));
        return params;
    }

    function deployAndRegister(DeploymentParams memory params) internal {
        sourceIts = IInterchainTokenService(params.sourceItsAddress);
        sourceFactory = IInterchainTokenFactory(params.sourceFactoryAddress);

        vm.startBroadcast(vm.envUint("TESTNET_PRIVATE_KEY"));

        console.log("Deploying interchain token");
        sourceFactory.deployInterchainToken(
            params.salt,
            params.name,
            params.symbol,
            params.decimals,
            params.amount,
            params.deployer
        );

        bytes32 tokenId = sourceFactory.interchainTokenId(
            params.deployer,
            params.salt
        );
        console.log("Token ID: %s", vm.toString(tokenId));

        address tokenAddress = sourceIts.interchainTokenAddress(tokenId);
        console.log("Token address: %s", tokenAddress);

        console.log("Deploying remote interchain token");
        sourceFactory.deployRemoteInterchainToken{value: FEE}(
            "",
            params.salt,
            params.deployer,
            StringUtils.toTitleCase(params.destinationChain),
            FEE
        );

        console.log("Deployment Information:");
        console.log("Source Chain: %s", params.sourceChain);
        console.log("Destination Chain: %s", params.destinationChain);
        console.log("Interchain Token Address: %s", tokenAddress);
        console.log("Token ID: %s", vm.toString(tokenId));

        vm.stopBroadcast();
    }

    function performInterchainTransfer(TransferParams memory params) internal {
        vm.startBroadcast(vm.envUint("TESTNET_PRIVATE_KEY"));

        sourceIts = IInterchainTokenService(params.sourceItsAddress);
        address tokenAddress = sourceIts.interchainTokenAddress(params.tokenId);
        IInterchainToken token = IInterchainToken(tokenAddress);

        console.log(
            "Performing interchain transfer of %s tokens",
            params.amount
        );

        uint256 balanceBeforeTransfer = token.balanceOf(params.deployer);
        console.log(
            "Source Chain Deployer Balance before transfer: %s",
            balanceBeforeTransfer
        );

        sourceIts.interchainTransfer{value: FEE}(
            params.tokenId,
            StringUtils.toTitleCase(params.destinationChain),
            abi.encodePacked(params.deployer),
            params.amount,
            "",
            FEE
        );

        uint256 balanceAfterTransfer = token.balanceOf(params.deployer);
        console.log(
            "Source Chain Deployer Balance after transfer: %s",
            balanceAfterTransfer
        );

        require(
            balanceAfterTransfer == balanceBeforeTransfer - params.amount,
            "Incorrect balance after transfer"
        );
        console.log("Interchain transfer completed");

        vm.stopBroadcast();
    }
}
