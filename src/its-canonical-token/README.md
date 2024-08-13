# Canonical Token Deployment Example

This example demonstrates how to deploy a canonical token and transfer it between different chains.

> Make sure you follow the command above to set up your local `.env` and start the local chains in a different terminal.

**Note**: This example uses the `CanonicalToken` contract. The `CanonicalToken` contract is deployed on the source chain and registered on the destination chain.

To execute the example, use the following command:

```
make deploy-canonical-token
```

The command will prompt you for the following information:

### Parameters

- `source_chain`: The blockchain network where the canonical token will be initially deployed. Acceptable values include "ethereum", "avalanche", "moonbeam", "fantom", and "polygon".
- `destination_chain`: The blockchain network where the token will be registered and transferred. Acceptable values include "ethereum", "avalanche", "moonbeam", "fantom", and "polygon".
- `token_name`: The name of the canonical token you want to create.
- `token_symbol`: The symbol for your canonical token.
- `token_decimals`: The number of decimal places for your token.
- `token_amount`: The initial amount of tokens to mint.

### Example

Here's an example of how you might respond to the prompts:

```
Enter source chain (ethereum, avalanche, moonbeam, fantom, polygon): ethereum
Enter destination chain (ethereum, avalanche, moonbeam, fantom, polygon): avalanche
Enter token name: My Canonical Token
Enter token symbol: MCT
Enter token decimals: 18
Enter initial token amount: 1000
```

### Process

1. The script will use the provided information to deploy the `CanonicalToken` contract on the source chain.
2. It will then register the token with the Interchain Token Service.
3. Finally, it will transfer the specified amount of tokens from the source chain to the destination chain.

### Output

The output will show debug information and the progress of the deployment, registration, and transfer process. A successful execution will end with:

```
make deploy-canonical-token
Deploying Canonical Token...
Enter source chain (ethereum, avalanche, moonbeam, fantom, polygon): polygon
Enter destination chain (ethereum, avalanche, moonbeam, fantom, polygon): fantom
Enter token name: My Canonical Token
Enter token symbol: MCT
Enter token decimals: 18
Enter initial token amount: 1000
Debug: Source Chain: POLYGON
Debug: Destination Chain: FANTOM
Debug: RPC URL: http://localhost:8549
Debug: Token Name: My Canonical Token
Debug: Token Symbol: MCT
Debug: Token Decimals: 18
Debug: Token Amount: 1000
Debug: Script path: script/local/its/CanonicalToken.s.sol
[⠒] Compiling...
[⠃] Compiling 1 files with 0.8.21
[⠊] Solc 0.8.21 finished in 716.62ms
Compiler run successful!
EIP-3855 is not supported in one or more of the RPCs used.
Unsupported Chain IDs: 31337.
Contracts deployed with a Solidity version equal or higher than 0.8.20 might not work properly.
For more information, please see https://eips.ethereum.org/EIPS/eip-3855
Script ran successfully.

== Logs ==
  Deploying canonical token for POLYGON
  Deployed CanonicalToken at 0x712516e61C8B383dF4A63CFe83d7701Bce54B03e
  Minted 1000 tokens to 0x70997970C51812dc3A010C7d01b50e0d17dc79C8
  Registering canonical token 0x712516e61C8B383dF4A63CFe83d7701Bce54B03e
  Token ID: 0x56956d73eb6558c4d34cbd905c044489202ee04ca716b8388006697b98408afb
  Deploying remote canonical token to FANTOM
  Waited for remote deployment
  Performing interchain transfer of 500 tokens
  Source Chain Deployer Balance before transfer: 1000
  Source Chain Deployer Balance after transfer: 500
  Interchain transfer completed

==========================

##### anvil-hardhat
✅  [Success]Hash: 0xacec18bc2478c3d4001a837bf4c5a3aa8f81339c6180d9bc2a97dba77297730a
Contract Address: 0x712516e61C8B383dF4A63CFe83d7701Bce54B03e

##### anvil-hardhat
✅  [Success]Hash: 0x2bdfbcacb78d4fdf835ee6d5f6607739e2c8a4b1807f08c02e9d1233078d2dd1

##### anvil-hardhat
✅  [Success]Hash: 0x1c9d79102cf102b05429fd431b805549ec6b24bcc49579c6d3215c403515379a

##### anvil-hardhat
✅  [Success]Hash: 0x8c19387ddead8ae3ad5f581a15eecaa8cba6e799d617928206dd74333e6b688e

##### anvil-hardhat
✅  [Success]Hash: 0x17ff3339e4c7ec780fcf8d66f69424475dbe8fd0e1c3044563d6786e177031b0

##### anvil-hardhat
✅  [Success]Hash: 0x7ce2ef6385c32af54ec6a2373db79ea4a16aa5d60f1ff06e5c9d4ed8eb765c57


==========================

ONCHAIN EXECUTION COMPLETE & SUCCESSFUL.
Total Paid: 0.002722420862089097 ETH (1789170 gas * avg 1.520125908 gwei)

Canonical Token deployment, registration, and transfer completed!
```

If there are any errors during the process, they will be displayed in red.
