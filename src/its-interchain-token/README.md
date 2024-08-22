# New Interchain Token Example

This example demonstrates how to deploy a new Interchain token and transfer it between different chains using the Axelar Interchain Token Service. The Interchain Token Service allows for seamless token transfers across multiple blockchain networks.

## Local

> Make sure to set up your local `.env` and start the local chains in a different terminal.

**Note**: This example uses the `InterchainToken` contract. The `InterchainToken` contract is deployed on the source chain and the destination chain.

To execute the example, use the following command:

```bash
make deploy-interchain-token
```

The command will prompt you for the following information:

### Parameters

- `source_chain`: The blockchain network where the token will be initially deployed. Acceptable values include "ethereum", "avalanche", "moonbeam", "fantom", and "polygon".
- `destination_chain`: The blockchain network to which the token will be transferred. Acceptable values include "ethereum", "avalanche", "moonbeam", "fantom", and "polygon".
- `token_name`: The name of the interchain token you want to create.
- `token_symbol`: The symbol for your interchain token.
- `token_decimals`: The number of decimal places for your token.
- `token_amount`: The initial amount of tokens to mint.

### Example

Here's an example of how you might respond to the prompts:

```bash
Enter source chain (ethereum, avalanche, moonbeam, fantom, polygon): ethereum
Enter destination chain (ethereum, avalanche, moonbeam, fantom, polygon): avalanche
Enter token name: My Interchain Token
Enter token symbol: MIT
Enter token decimals: 18
Enter initial token amount: 1000
```

### Process

1. The script will use the provided information to deploy the `InterchainToken` contract on the source chain.
2. It will then register the token with the Interchain Token Service.
3. Finally, it will transfer the specified amount of tokens from the source chain to the destination chain.

## Local Output

The output will show debug information and the progress of the deployment and transfer process. A successful execution will end with:

```bash
make deploy-interchain-token
Deploying Interchain Token...
Enter source chain (ethereum, avalanche, moonbeam, fantom, polygon): ethereum
Enter destination chain (ethereum, avalanche, moonbeam, fantom, polygon): polygon
Enter token name: My Interchain Token
Enter token symbol: MIT
Enter token decimals: 18
Enter initial token amount: 1000
Debug: Source Chain: ETHEREUM
Debug: Destination Chain: POLYGON
Debug: RPC URL: http://localhost:8545
Debug: Token Name: My Interchain Token
Debug: Token Symbol: MIT
Debug: Token Decimals: 18
Debug: Token Amount: 1000
Debug: Script path: script/local/its/InterchainToken.s.sol
[⠒] Compiling...
[⠘] Compiling 1 files with 0.8.21
[⠊] Solc 0.8.21 finished in 642.69ms
Compiler run successful!
EIP-3855 is not supported in one or more of the RPCs used.
Unsupported Chain IDs: 31337.
Contracts deployed with a Solidity version equal or higher than 0.8.20 might not work properly.
For more information, please see https://eips.ethereum.org/EIPS/eip-3855
Script ran successfully.

== Logs ==
  Deploying interchain token
  Token ID: 0x559ac05240259c05b23eca3fbe26875fa5a4a68c38fb89087bcc146a4cf9d528
  Token address: 0x47Da9d72772A38Bf51fE2D6A48146e6d8a2cB845
  Initial balance of deployer: 1000
  Token validated successfully
  Deploying remote interchain token
  Waited for remote deployment
  Remote token address: 0x47Da9d72772A38Bf51fE2D6A48146e6d8a2cB845
  Performing interchain transfer of 500 tokens
  Source Chain Deployer Balance before transfer: 1000
  Source Chain Deployer Balance after transfer: 500
  Interchain transfer completed
  Destination Chain Total supply: 500
  Destination Chain Deployer balance after transfer: 500
  Token Manager address: 0x7E034E8D16B92A7147866446A7e0F0C0E605891B

==========================
##### anvil-hardhat
✅  [Success]Hash: 0x9574ae0f11901639d24499674ca05f4e4084ca311de108d6903e9bdfa1a92156

##### anvil-hardhat
✅  [Success]Hash: 0x9ff09efc8094886d9dd6b23f210a85520c7f4a2c0ac59ecc0857d7da3600f901

##### anvil-hardhat
✅  [Success]Hash: 0xfb7d1d54d4d1486dafeb066ab4da2485c14d90b6d4914ccdfed808c0217f42e0

==========================

ONCHAIN EXECUTION COMPLETE & SUCCESSFUL.
Total Paid: 0.001781952890449216 ETH (1161244 gas * avg 1.531741712 gwei)

Interchain Token deployment and transfer completed!
```

If there are any errors during the process, they will be displayed in red.

## Testnet

> Make sure to set up your local `.env` file with the necessary testnet RPC URLs and your `TESTNET_PRIVATE_KEY`.

To deploy and transfer the Interchain Token on testnet, you'll use two separate commands: one for deployment and one for transfer.

### Deploying Interchain Token on Testnet

To deploy the Interchain Token on a testnet, use the following command:

```bash
make deploy-interchain-token-testnet
```

The command will prompt you for the following information:

#### Parameters

- `source_chain`: The testnet blockchain network where the token will be initially deployed. Acceptable values include "ethereum", "avalanche", "moonbeam", "fantom", and "polygon".
- `destination_chain`: The testnet blockchain network to which the token will be transferred. Acceptable values include "ethereum", "avalanche", "moonbeam", "fantom", and "polygon".
- `token_name`: The name of the interchain token you want to create.
- `token_symbol`: The symbol for your interchain token.
- `token_decimals`: The number of decimal places for your token.
- `token_amount`: The initial amount of tokens to mint.

#### Example

Here's an example of how you might respond to the prompts:

```bash
Enter source chain (ethereum, avalanche, moonbeam, fantom, polygon): avalanche
Enter destination chain (ethereum, avalanche, moonbeam, fantom, polygon): fantom
Enter token name: My Testnet Interchain Token
Enter token symbol: MTIT
Enter token decimals: 18
Enter initial token amount to be minted: 1000
```

After the deployment is complete, the script will output important information, including the Token ID. Make sure to note this down as you'll need it for the transfer step.

**Important**: Before proceeding to the transfer step, confirm that the deployment was successful by checking the transaction on [Axelar Testnet Explorer](https://testnet.axelarscan.io). Search for your transaction hash or address to verify the deployment.

### Transferring Interchain Token on Testnet

After confirming the successful deployment, you can proceed with the transfer using the following command:

```bash
make transfer-interchain-token-testnet
```

The command will prompt you for the following information:

#### Parameters

- `source_chain`: The testnet blockchain network from which you want to transfer tokens.
- `destination_chain`: The testnet blockchain network to which you want to transfer tokens.
- `token_id`: The Token ID noted from the deployment step.
- `transfer_amount`: The amount of tokens you want to transfer.

#### Example

Here's an example of how you might respond to the prompts:

```bash
Enter source chain (ethereum, avalanche, moonbeam, fantom, polygon): avalanche
Enter destination chain (ethereum, avalanche, moonbeam, fantom, polygon): fantom
Enter token ID: 0x1234... # Use the actual Token ID from the deployment step
Enter amount to transfer: 500
```

### Important Notes

1. Ensure you have sufficient testnet tokens (e.g., Avalanche testnet AVAX) in your wallet to cover gas fees for both deployment and transfer operations.
2. Set your `TESTNET_PRIVATE_KEY` in the `.env` file. This should be the private key of the account you're using for testnet operations.
3. After deployment, always verify the transaction on the [Axelar Testnet Explorer](https://testnet.axelarscan.io) before proceeding with the transfer.
4. Testnet operations may take longer than local operations. Be patient and monitor the transaction status on the respective testnet explorers.

If you encounter any errors during the process, they will be displayed in red. Make sure to resolve any issues before proceeding to the next step.
