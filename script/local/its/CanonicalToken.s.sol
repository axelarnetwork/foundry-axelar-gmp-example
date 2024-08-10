// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "@axelarnetwork/interchain-token-service/contracts/interfaces/IInterchainTokenService.sol";
import "@axelarnetwork/interchain-token-service/contracts/interfaces/IInterchainTokenFactory.sol";
import "@axelarnetwork/interchain-token-service/contracts/interfaces/IInterchainToken.sol";
import "../../utils/StringUtils.sol";
import "../../../src/its-canonical-token/CanonicalToken.sol";

contract CanonicalTokenScript is Script {
    IInterchainTokenService public sourceIts;
    IInterchainTokenFactory public sourceFactory;
    IInterchainTokenService public destinationIts;

    uint256 constant WAIT_TIME = 10;
    uint256 constant TRANSFER_PERCENTAGE = 50; // 50%
    uint256 constant FEE = 1 ether;

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

    function run() public {
        deployTokens(getDeploymentParams());
    }

    function validateChain(
        string memory chain
    ) internal pure returns (string memory) {
        bytes32 chainHash = keccak256(abi.encodePacked(chain));
        if (
            chainHash == keccak256("ETHEREUM") ||
            chainHash == keccak256("AVALANCHE") ||
            chainHash == keccak256("MOONBEAM") ||
            chainHash == keccak256("FANTOM") ||
            chainHash == keccak256("POLYGON")
        ) {
            return chain;
        }
        revert("Invalid chain");
    }

    function getDeploymentParams()
        internal
        view
        returns (DeploymentParams memory)
    {
        DeploymentParams memory params;
        params.sourceChain = validateChain(vm.envString("SOURCE_CHAIN"));
        params.destinationChain = validateChain(
            vm.envString("DESTINATION_CHAIN")
        );
        params.sourceItsAddress = vm.envAddress(
            string(
                abi.encodePacked(
                    "LOCAL_",
                    params.sourceChain,
                    "_INTERCHAIN_TOKEN_SERVICE"
                )
            )
        );
        params.sourceFactoryAddress = vm.envAddress(
            string(
                abi.encodePacked(
                    "LOCAL_",
                    params.sourceChain,
                    "_INTERCHAIN_TOKEN_FACTORY"
                )
            )
        );
        params.destinationItsAddress = vm.envAddress(
            string(
                abi.encodePacked(
                    "LOCAL_",
                    params.destinationChain,
                    "_INTERCHAIN_TOKEN_SERVICE"
                )
            )
        );
        params.name = vm.envString("TOKEN_NAME");
        params.symbol = vm.envString("TOKEN_SYMBOL");
        params.decimals = uint8(vm.envUint("TOKEN_DECIMALS"));
        params.amount = vm.envUint("TOKEN_AMOUNT");
        params.deployer = vm.addr(vm.envUint("LOCAL_PRIVATE_KEY"));
        return params;
    }

    function deployTokens(DeploymentParams memory params) internal {
        sourceIts = IInterchainTokenService(params.sourceItsAddress);
        sourceFactory = IInterchainTokenFactory(params.sourceFactoryAddress);
        destinationIts = IInterchainTokenService(params.destinationItsAddress);

        vm.startBroadcast(vm.envUint("LOCAL_PRIVATE_KEY"));

        address canonicalToken = deploySourceToken(params);
        bytes32 tokenId = registerAndDeployRemoteToken(canonicalToken, params);
        performInterchainTransfer(tokenId, canonicalToken, params);

        vm.stopBroadcast();
    }

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

        vm.warp(block.timestamp + WAIT_TIME);
        console.log("Waited for remote deployment");

        return tokenId;
    }

    function performInterchainTransfer(
        bytes32 tokenId,
        address tokenAddress,
        DeploymentParams memory params
    ) internal {
        CanonicalToken token = CanonicalToken(tokenAddress);
        uint256 transferAmount = (params.amount * TRANSFER_PERCENTAGE) / 100;
        console.log(
            "Performing interchain transfer of %s tokens",
            transferAmount
        );

        uint256 balanceBeforeTransfer = token.balanceOf(params.deployer);
        console.log(
            "Source Chain Deployer Balance before transfer: %s",
            balanceBeforeTransfer
        );

        token.approve(address(sourceIts), transferAmount);

        sourceIts.interchainTransfer{value: FEE}(
            tokenId,
            StringUtils.toTitleCase(params.destinationChain),
            abi.encodePacked(params.deployer),
            transferAmount,
            "",
            FEE
        );

        uint256 balanceAfterTransfer = token.balanceOf(params.deployer);
        console.log(
            "Source Chain Deployer Balance after transfer: %s",
            balanceAfterTransfer
        );

        require(
            balanceAfterTransfer == balanceBeforeTransfer - transferAmount,
            "Incorrect balance after transfer"
        );
        console.log("Interchain transfer completed");
    }
}
