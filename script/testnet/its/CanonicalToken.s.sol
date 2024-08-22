// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "@axelarnetwork/interchain-token-service/contracts/interfaces/IInterchainTokenService.sol";
import "@axelarnetwork/interchain-token-service/contracts/interfaces/IInterchainTokenFactory.sol";
import "@axelarnetwork/interchain-token-service/contracts/interfaces/IInterchainToken.sol";
import "../../utils/StringUtils.sol";
import "../../../src/its-canonical-token/CanonicalToken.sol";

/// @title CanonicalTokenScript
/// @notice Script for deploying and transferring canonical tokens across chains
contract CanonicalTokenScript is Script {
    IInterchainTokenService public sourceIts;
    IInterchainTokenFactory public sourceFactory;
    IInterchainTokenService public destinationIts;

    uint256 constant FEE = 0.01 ether; // Adjust as needed for testnet

    struct DeploymentParams {
        string sourceChain;
        string destinationChain;
        address sourceItsAddress;
        address sourceFactoryAddress;
        address destinationItsAddress;
        string name;
        string symbol;
        uint8 decimals;
        uint256 amount;
        address deployer;
    }

    struct TransferParams {
        string sourceChain;
        string destinationChain;
        address sourceItsAddress;
        address canonicalTokenAddress;
        bytes32 tokenId;
        uint256 amount;
        address deployer;
    }

    /// @notice Deploy and register a new canonical token
    function deploy() public {
        DeploymentParams memory params = getDeploymentParams();
        deployAndRegister(params);
    }

    /// @notice Transfer tokens across chains
    function transfer() public {
        TransferParams memory params = getTransferParams();
        performInterchainTransfer(params);
    }

    /// @notice Get deployment parameters from environment variables
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
        params.destinationItsAddress = vm.envAddress(
            "TESTNET_INTERCHAIN_TOKEN_SERVICE"
        );
        params.name = vm.envString("TOKEN_NAME");
        params.symbol = vm.envString("TOKEN_SYMBOL");
        params.decimals = uint8(vm.envUint("TOKEN_DECIMALS"));
        params.amount = vm.envUint("TOKEN_AMOUNT") * 1e18;
        params.deployer = vm.addr(vm.envUint("TESTNET_PRIVATE_KEY"));
        return params;
    }

    /// @notice Get transfer parameters from environment variables
    function getTransferParams() internal view returns (TransferParams memory) {
        TransferParams memory params;
        params.sourceChain = vm.envString("NETWORK");
        params.destinationChain = vm.envString("DESTINATION_CHAIN");
        params.sourceItsAddress = vm.envAddress(
            "TESTNET_INTERCHAIN_TOKEN_SERVICE"
        );
        params.canonicalTokenAddress = vm.envAddress("CANONICAL_TOKEN_ADDRESS");
        params.tokenId = bytes32(vm.envBytes32("TOKEN_ID"));
        params.amount = vm.envUint("TOKEN_AMOUNT") * 1e18;
        params.deployer = vm.addr(vm.envUint("TESTNET_PRIVATE_KEY"));
        return params;
    }

    /// @notice Deploy and register a new canonical token
    function deployAndRegister(DeploymentParams memory params) internal {
        sourceIts = IInterchainTokenService(params.sourceItsAddress);
        sourceFactory = IInterchainTokenFactory(params.sourceFactoryAddress);

        vm.startBroadcast(vm.envUint("TESTNET_PRIVATE_KEY"));

        address canonicalToken = deploySourceToken(params);
        bytes32 tokenId = registerAndDeployRemoteToken(canonicalToken, params);

        // Log important information
        console.log("Deployment Information:");
        console.log("Source Chain: %s", params.sourceChain);
        console.log("Destination Chain: %s", params.destinationChain);
        console.log("Canonical Token Address: %s", canonicalToken);
        console.log("Token ID: %s", vm.toString(tokenId));

        vm.stopBroadcast();
    }

    /// @notice Deploy the source token
    function deploySourceToken(
        DeploymentParams memory params
    ) internal returns (address) {
        console.log("Deploying canonical token for %s", params.sourceChain);
        CanonicalToken canonicalToken = new CanonicalToken(
            params.name,
            params.symbol,
            params.decimals
        );
        console.log("Deployed CanonicalToken at %s", address(canonicalToken));

        canonicalToken.mint(params.deployer, params.amount);
        console.log("Minted %d tokens to %s", params.amount, params.deployer);

        return address(canonicalToken);
    }

    /// @notice Register and deploy the remote token
    function registerAndDeployRemoteToken(
        address canonicalToken,
        DeploymentParams memory params
    ) internal returns (bytes32) {
        console.log("Registering canonical token %s", canonicalToken);
        sourceFactory.registerCanonicalInterchainToken(canonicalToken);

        bytes32 tokenId = sourceFactory.canonicalInterchainTokenId(
            canonicalToken
        );
        console.log("Token ID: %s", vm.toString(tokenId));

        console.log(
            "Deploying remote canonical token to %s",
            params.destinationChain
        );
        sourceFactory.deployRemoteCanonicalInterchainToken{value: FEE}(
            StringUtils.toTitleCase(params.sourceChain),
            canonicalToken,
            StringUtils.toTitleCase(params.destinationChain),
            FEE
        );

        return tokenId;
    }

    /// @notice Perform an interchain transfer
    function performInterchainTransfer(TransferParams memory params) internal {
        vm.startBroadcast(vm.envUint("TESTNET_PRIVATE_KEY"));

        sourceIts = IInterchainTokenService(params.sourceItsAddress);
        CanonicalToken token = CanonicalToken(params.canonicalTokenAddress);

        console.log(
            "Performing interchain transfer of %s tokens",
            params.amount
        );

        uint256 balanceBeforeTransfer = token.balanceOf(params.deployer);
        console.log(
            "Source Chain Deployer Balance before transfer: %s",
            balanceBeforeTransfer
        );

        token.approve(address(sourceIts), params.amount);

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
