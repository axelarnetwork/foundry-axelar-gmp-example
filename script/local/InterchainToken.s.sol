// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "@axelarnetwork/interchain-token-service/contracts/interfaces/IInterchainTokenService.sol";
import "@axelarnetwork/interchain-token-service/contracts/interfaces/IInterchainTokenFactory.sol";
import "@axelarnetwork/interchain-token-service/contracts/interfaces/IInterchainToken.sol";

contract InterchainTokenScript is Script {
    IInterchainTokenService public sourceIts;
    IInterchainTokenFactory public sourceFactory;
    IInterchainTokenService public destinationIts;

    uint256 constant WAIT_TIME = 10;
    uint256 constant TRANSFER_PERCENTAGE = 50; // 50%
    uint256 constant FEE = 0.002 ether;

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
        bytes32 salt;
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
        params.salt = keccak256(abi.encodePacked(block.timestamp, msg.sender));
        params.deployer = vm.addr(vm.envUint("LOCAL_PRIVATE_KEY"));
        return params;
    }

    function deployTokens(DeploymentParams memory params) internal {
        sourceIts = IInterchainTokenService(params.sourceItsAddress);
        sourceFactory = IInterchainTokenFactory(params.sourceFactoryAddress);
        destinationIts = IInterchainTokenService(params.destinationItsAddress);

        vm.startBroadcast(vm.envUint("LOCAL_PRIVATE_KEY"));

        bytes32 tokenId = deploySourceToken(params);
        address tokenAddress = validateSourceToken(tokenId, params);
        deployRemoteToken(tokenId, params);
        performInterchainTransfer(tokenId, tokenAddress, params);
        validateDestinationToken(tokenId, params);

        vm.stopBroadcast();
    }

    function deploySourceToken(
        DeploymentParams memory params
    ) internal returns (bytes32) {
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
        return tokenId;
    }

    function validateSourceToken(
        bytes32 tokenId,
        DeploymentParams memory params
    ) internal returns (address) {
        address tokenAddress = sourceIts.interchainTokenAddress(tokenId);
        require(
            tokenAddress != address(0),
            "Token deployment failed: Zero address returned"
        );
        console.log("Token address: %s", tokenAddress);

        IInterchainToken token = IInterchainToken(tokenAddress);
        require(
            keccak256(abi.encodePacked(token.name())) ==
                keccak256(abi.encodePacked(params.name)),
            "Token name mismatch"
        );
        require(
            keccak256(abi.encodePacked(token.symbol())) ==
                keccak256(abi.encodePacked(params.symbol)),
            "Token symbol mismatch"
        );
        require(token.decimals() == params.decimals, "Token decimals mismatch");

        uint256 initialBalance = token.balanceOf(params.deployer);
        require(initialBalance == params.amount, "Initial balance mismatch");
        console.log("Initial balance of deployer: %s", initialBalance);

        console.log("Token validated successfully");
        return tokenAddress;
    }

    function deployRemoteToken(
        bytes32 tokenId,
        DeploymentParams memory params
    ) internal {
        console.log("Deploying remote interchain token");
        sourceFactory.deployRemoteInterchainToken{value: FEE}(
            "",
            params.salt,
            params.deployer,
            toTitleCase(params.destinationChain),
            FEE
        );

        vm.warp(block.timestamp + WAIT_TIME);
        console.log("Waited for remote deployment");

        address destinationTokenAddress = destinationIts.interchainTokenAddress(
            tokenId
        );
        require(
            destinationTokenAddress != address(0),
            "Remote token deployment failed: Zero address returned"
        );
        console.log("Remote token address: %s", destinationTokenAddress);
    }

    function performInterchainTransfer(
        bytes32 tokenId,
        address tokenAddress,
        DeploymentParams memory params
    ) internal {
        IInterchainToken token = IInterchainToken(tokenAddress);
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

        sourceIts.interchainTransfer{value: FEE}(
            tokenId,
            toTitleCase(params.destinationChain),
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

    function validateDestinationToken(
        bytes32 tokenId,
        DeploymentParams memory params
    ) internal {
        address destTokenAddress = destinationIts.interchainTokenAddress(
            tokenId
        );
        IInterchainToken destToken = IInterchainToken(destTokenAddress);
        uint256 transferAmount = (params.amount * TRANSFER_PERCENTAGE) / 100;

        require(
            destToken.totalSupply() == transferAmount,
            "Destination chain total supply mismatch"
        );
        console.log(
            "Destination Chain Total supply: %s",
            destToken.totalSupply()
        );

        uint256 destBalance = destToken.balanceOf(params.deployer);
        console.log(
            "Destination Chain Deployer balance after transfer: %s",
            destBalance
        );
        require(
            destBalance == transferAmount,
            "Incorrect balance on destination chain"
        );

        address tokenManager = destinationIts.tokenManagerAddress(tokenId);
        console.log("Token Manager address: %s", tokenManager);
        require(tokenManager != address(0), "Token Manager not set");
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
