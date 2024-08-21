# Interchain Custom Token Example

This example demonstrates how to set up token managers for a custom token and transfer it between different chains using the Axelar Interchain Token Service. The Interchain Token Service allows for seamless token transfers across multiple blockchain networks.

## Local

> Make sure to set up your local `.env` and start the local chains in a different terminal.

**Note**: This example uses the `InterchainToken` contract. The `InterchainToken` contract is deployed on the source chain and the destination chain.

To execute the example, use the following command:

```bash
make deploy-mint-burn-token-manager-and-transfer
```

The command will prompt you for the following information:

### Parameters

- `SOURCE_NETWORK`: The blockchain network where the source custom token is deployed. Acceptable values include "ethereum", "avalanche", "moonbeam", "fantom", and "polygon".
- `DEST_NETWORK`: The blockchain network where the destination custom token is deployed. Acceptable values include "ethereum", "avalanche", "moonbeam", "fantom", and "polygon".
- `MINT_AMOUNT`: The amount of tokens to mint on the source chain.
- `TRANSFER_AMOUNT`: The amount of tokens to transfer from the source chain to the destination chain.

### Example

Here's an example of how you might respond to the prompts:

```
Enter source network (ethereum, avalanche, moonbeam, fantom, polygon): ethereum
Enter destination network (ethereum, avalanche, moonbeam, fantom, polygon): avalanche
Enter amount to mint: 1000
Enter amount to transfer: 500
```

### Process

1. The script will retrieve the addresses of the custom tokens from the `.env` file for both the source and destination networks.
2. It will then set up mint/burn token managers for both the source and destination tokens.
3. The specified amount of tokens will be approved and minted on the source chain.
4. Finally, it will transfer the specified amount of tokens from the source chain to the destination chain.

## Local Output

The output will show debug information and the progress of the token manager setup, approval minting, and transfer process. A successful execution will end with a message indicating that the Forge script execution was successful.

Example output:

```bash
make deploy-mint-burn-token-manager-and-transfer
Setting up Token Managers...
Enter source network (ethereum, avalanche, moonbeam, fantom, polygon): avalanche
Enter destination network (ethereum, avalanche, moonbeam, fantom, polygon): polygon
Enter amount to mint: 1000
Enter amount to transfer: 500
Debug: Source Network: avalanche
Debug: Destination Network: polygon
Debug: Source Token: 0x948B3c65b89DF0B4894ABE91E6D02FE579834F8F
Debug: Destination Token: 0x948B3c65b89DF0B4894ABE91E6D02FE579834F8F
Debug: Mint Amount: 1000
Debug: Transfer Amount: 500
[⠒] Compiling...
No files changed, compilation skipped
EIP-3855 is not supported in one or more of the RPCs used.
Unsupported Chain IDs: 31337.
Contracts deployed with a Solidity version equal or higher than 0.8.20 might not work properly.
For more information, please see https://eips.ethereum.org/EIPS/eip-3855
Script ran successfully.

== Logs ==
  ==== Setup Configuration ====
  Source Network: avalanche
  Destination Network: polygon
  Source ITS Address: 0x7DaC9A4a7542D635739b43665aD49b8C7E115f0A
  Destination ITS Address: 0x7DaC9A4a7542D635739b43665aD49b8C7E115f0A
  Source Token Address: 0x948B3c65b89DF0B4894ABE91E6D02FE579834F8F
  Destination Token Address: 0x948B3c65b89DF0B4894ABE91E6D02FE579834F8F
  Mint Amount: 1000
  Transfer Amount: 500
  =============================
  Deployer address: 0x70997970C51812dc3A010C7d01b50e0d17dc79C8

==== Setting Trusted Addresses ====
  Warning: Not owner of source ITS, skipping setTrustedAddress
  Warning: Not owner of destination ITS, skipping setTrustedAddress

Salt for token deployments: 0x0b07caf6bbefc5f7cc1e8116d56013fe2e7fd9bfd746a3876c9ab2faac472d6c

==== Deploying Token Managers ====
  Deploying token manager for avalanche network...
  Token manager deployed successfully for avalanche network
  Added token manager 0x2B29839eA4836b35cE8b6a4f5E493299B9725C3D as minter for CustomToken on avalanche
  Deploying token manager for polygon network...
  Token manager deployed successfully for polygon network
  Added token manager 0x2B29839eA4836b35cE8b6a4f5E493299B9725C3D as minter for CustomToken on polygon

Token ID: 0x67a0f8f39c9a96c943623ffde384a537aa78d0f14537b7219a56790e1270f106

==== Initial Balances ====
  Source chain initial balance: 0
  Destination chain initial balance: 0

==== Minting Tokens ====
  Minted 1000 tokens to 0x70997970C51812dc3A010C7d01b50e0d17dc79C8 on source chain
  Source chain balance after minting: 1000

==== Initiating Interchain Transfer ====
  Performing interchain transfer...
  Interchain transfer initiated successfully

==== Final Balances ====
  Source chain final balance: 500
  Destination chain final balance: 500
  Note: The destination chain balance may not reflect the transfer immediately due to the nature of cross-chain transactions.

==== Transfer Summary ====
  Tokens minted on source chain: 1000
  Tokens transferred to destination chain: 500
  Change in source chain balance: 500

==========================

##### anvil-hardhat
✅  [Success]Hash: 0x0838ecb386e423cd1fc2b3e2b64473896f71b2cc869e1429ad10410d67db4f65

##### anvil-hardhat
✅  [Success]Hash: 0xafb7c700595f250c02048d205913abe0ecebebc7a4f95439faf3d4ad1ca846dc

##### anvil-hardhat
✅  [Success]Hash: 0x1df4e576a359648f46827c225ad26eaf7f54d1e61647d517240b42b3f2b6460c

##### anvil-hardhat
✅  [Success]Hash: 0x88fa0a9ec8547d650e901a8e7a7aa53fe99afe24fccd612853aafe5722a5b361

##### anvil-hardhat
✅  [Success]Hash: 0x5c8eb112ac41f979d8237b616ec725e1896e35d87c20c68cfac9479bb8ffb242

##### anvil-hardhat
✅  [Success]Hash: 0x3aebbbeea5ee5909e657aa484746af0a1b580c36e413cae8a8146fd5ff6850fe
==========================

ONCHAIN EXECUTION COMPLETE & SUCCESSFUL.
```

If there are any errors during the process, they will be displayed in red.

## Testnet

> Make sure to set up your local `.env` file with the necessary testnet RPC URLs and your `TESTNET_PRIVATE_KEY`.

To deploy and transfer the Custom Token on testnet, you'll use two separate commands: one for deployment and one for transfer.

### Deploying Custom Token on Testnet

To deploy the Custom Token on a testnet, use the following command:

```bash
make deploy-custom-token-testnet
```

The command will prompt you for the following information:

#### Parameters

- `source_chain`: The testnet blockchain network where the token will be initially deployed. Acceptable values include "ethereum", "avalanche", "moonbeam", "fantom", and "polygon".
- `destination_chain`: The testnet blockchain network to which the token will be transferred. Acceptable values include "ethereum", "avalanche", "moonbeam", "fantom", and "polygon".
- `token_name`: The name of the custom token you want to create.
- `token_symbol`: The symbol for your custom token.
- `token_decimals`: The number of decimal places for your token.
- `token_amount`: The initial amount of tokens to mint.

#### Example

Here's an example of how you might respond to the prompts:

```bash
Enter source chain (ethereum, avalanche, moonbeam, fantom, polygon): avalanche
Enter destination chain (ethereum, avalanche, moonbeam, fantom, polygon): fantom
Enter token name: My Testnet Custom Token
Enter token symbol: MTCT
Enter token decimals: 18
Enter initial token amount to be minted: 1000
```

After the deployment is complete, the script will output important information, including the Token ID and token addresses. Make sure to note these down as you'll need them for the transfer step.

**Important**: Before proceeding to the transfer step, confirm that the deployment was successful by checking the transaction on [Axelar Testnet Explorer](https://testnet.axelarscan.io). Search for your transaction hash or address to verify the deployment.

### Transferring Custom Token on Testnet

After confirming the successful deployment, you can proceed with the transfer using the following command:

```bash
make transfer-custom-token-testnet
```

The command will prompt you for the following information:

#### Parameters

- `source_chain`: The testnet blockchain network from which you want to transfer tokens.
- `destination_chain`: The testnet blockchain network to which you want to transfer tokens.
- `token_address`: The address of the deployed Custom Token (noted from the deployment step).
- `token_id`: The Token ID noted from the deployment step.
- `transfer_amount`: The amount of tokens you want to transfer.

#### Example

Here's an example of how you might respond to the prompts:

```bash
Enter source chain (ethereum, avalanche, moonbeam, fantom, polygon): avalanche
Enter destination chain (ethereum, avalanche, moonbeam, fantom, polygon): fantom
Enter token address: 0x1234... # Use the actual Token Address from the deployment step
Enter token ID: 0x5678... # Use the actual Token ID from the deployment step
Enter amount to transfer: 500
```

### Important Notes

1. Ensure you have sufficient testnet tokens (e.g., Avalanche testnet AVAX) in your wallet to cover gas fees for both deployment and transfer operations.
2. Set your `TESTNET_PRIVATE_KEY` in the `.env` file. This should be the private key of the account you're using for testnet operations.
3. After deployment, always verify the transaction on the [Axelar Testnet Explorer](https://testnet.axelarscan.io) before proceeding with the transfer.
4. Testnet operations may take longer than local operations. Be patient and monitor the transaction status on the respective testnet explorers.

If you encounter any errors during the process, they will be displayed in red. Make sure to resolve any issues before proceeding to the next step.
