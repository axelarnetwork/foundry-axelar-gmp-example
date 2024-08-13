# Interchain Custom Token Example

This example demonstrates how to set up token managers for a custom token and transfer it between different chains.

> Make sure you follow the command above to set up your local `.env` and start the local chains in a different terminal.

**Note**: This example assumes you have already deployed custom tokens on both the source and destination chains.

To execute the example, use the following command:

```
make deploy-mint-burn-token-manager-and-transfer
```

The command will prompt you for the following information:

## Parameters

- `SOURCE_NETWORK`: The blockchain network where the source custom token is deployed. Acceptable values include "ethereum", "avalanche", "moonbeam", "fantom", and "polygon".
- `DEST_NETWORK`: The blockchain network where the destination custom token is deployed. Acceptable values include "ethereum", "avalanche", "moonbeam", "fantom", and "polygon".
- `MINT_AMOUNT`: The amount of tokens to mint on the source chain.
- `TRANSFER_AMOUNT`: The amount of tokens to transfer from the source chain to the destination chain.

## Example

Here's an example of how you might respond to the prompts:

```
Enter source network (ethereum, avalanche, moonbeam, fantom, polygon): ethereum
Enter destination network (ethereum, avalanche, moonbeam, fantom, polygon): avalanche
Enter amount to mint: 1000
Enter amount to transfer: 500
```

## Process

1. The script will retrieve the addresses of the custom tokens from the `.env` file for both the source and destination networks.
2. It will then set up mint/burn token managers for both the source and destination tokens.
3. The specified amount of tokens will be approved and minted on the source chain.
4. Finally, it will transfer the specified amount of tokens from the source chain to the destination chain.

## Output

The output will show debug information and the progress of the token manager setup, approval minting, and transfer process. A successful execution will end with a message indicating that the Forge script execution was successful.

Example output:

```
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
