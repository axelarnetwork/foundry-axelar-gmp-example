# Call Contract Example

This example demonstrates how to relay a message from a source chain to a destination chain.

## Local

> Make sure you follow the command above to set up your local `.env` and start the local chains in a different terminal.

To execute the example, use the following command:

```
make local-chain-execute FROM={srcChain} TO={destChain} SCRIPT={script} VALUE={gasValue} MESSAGE={message}
```

## Parameters

- `srcChain`: The blockchain network from which the message will be relayed. Acceptable values include "Moonbeam", "Avalanche", "Fantom", "Ethereum", and "Polygon".

- `destChain`: The blockchain network to which the message will be relayed. Acceptable values include "Moonbeam", "Avalanche", "Fantom", "Ethereum", and "Polygon".

- `script`: The contract to execute on the blockchain network.

- `gasValue`: The gas amount to pay for cross-chain interactions.

- `message`: The message to be relayed between the chains.

## Example

This example relays the message "Hello World" from Fantom to Polygon.

```
make local-chain-execute FROM=Fantom TO=Polygon SCRIPT=ExecutableSample VALUE=1 MESSAGE="Hello World"
```

**The output will be**:

```
Using local private key for transactions...
SRC_RPC_URL: http://localhost:8548
DEST_RPC_URL: http://localhost:8549
Reading initial state from destination network (POLYGON)...
Value: ""
Source Chain: "Fantom"
Executing setRemoteValue for ExecutableSample...

blockHash               0x716e05da395a0f0862fd4a42d339c495c78678bc7897440b5b6e7297e2f54f85
blockNumber             52
contractAddress
cumulativeGasUsed       60657
effectiveGasPrice       3001641916
gasUsed                 60657
logs                    [{...}]
logsBloom               0x0
status                  1
transactionHash         0x51cf7899a9832bd415b51f743e6a853d1ca817e497d66e2f51009d8f6efb6566
transactionIndex        0
type                    2
Transaction sent successfully.
Reading final state from destination network (POLYGON)...

Value: "Hello World"
Source Chain: "Fantom"
Operation completed successfully!
```

## Testnet

Update the `TESTNET_PRIVATE_KEY` variable with your private key in your `.env`

```bash
TESTNET_PRIVATE_KEY=0xYOUR_KEY_HERE
```

> ⚠️ WARNING: Never commit your`TESTNET_PRIVATE_KEY` to any public repository or share it with anyone. Exposing your private key compromises the security of your assets and can result in loss or theft. Always keep it confidential and store it securely. If you believe your private key has been exposed, take immediate action to secure your accounts.

### Deployment

To deploy to any of your preferred test networks this project supports, ensure you have tokens from a faucet for the respective network. You can acquire faucet tokens for the Polygon Mumbai testnet [here](https://faucet.polygon.technology/), for Avalanche [here](https://docs.avax.network/build/dapp/smart-contracts/get-funds-faucet), and for Moonbeam [here](https://faucet.moonbeam.network/). For Fantom, [here](https://faucet.fantom.network/) and for Ethereum Sepolia, use this [link](https://www.alchemy.com/faucets/ethereum-sepolia). Ensure these tokens are in the account linked to the private key you provided in your `.env` file.

Next, run the following command.

```bash
make deploy NETWORK=network SCRIPT=script
```

The `SCRIPT` parameter specifies which smart contract or script you wish to deploy to the blockchain network. Think of it as the "what" you're deploying, whereas the `NETWORK` parameter is the "where" you're deploying to.

### Example

```bash
make deploy NETWORK=polygon SCRIPT=ExecutableSample
```

The above command deploys the `ExecutableSample` contract to the Polygon Mumbai testnet. This script can also be used to target other contracts within the project.

### Execution

To send a message using Axelar GMP is quite simple; what is required is to run `make execute` and pass the appropriate parameters needed, and you will be able to test the contract deployed.

We assume you have already deployed your contract and that both source and destination chain contract addresses are available.

Let's look at an example using `ExecutableSample`; this process is similar to the other available contracts.

We have deployed `ExecutableSample` on `Polygon` here: [0xc399215e17114437C36BCD6b8B85d8D2452fBea8](https://mumbai.polygonscan.com/address/0xc399215e17114437C36BCD6b8B85d8D2452fBea8) and on `Avalanche` here: [0x9fee1724451844198613fC6F84600A727cB2752A](https://testnet.snowtrace.io/address/0x9fee1724451844198613fC6F84600A727cB2752A) for this example.

Run the following command:

```
make execute-gmp-on-testnet
```

You should get the following response similar to what we have below if you are also testing with the `ExecutableSample` contract.

```
Please enter the details:
Contract Name (e.g., ExecutableSample, DistributionExecutable, SendAck): ExecutableSample
Network (e.g., ethereum, avalanche, moonbeam, fantom, polygon): polygon
Source chain contract address: 0xc399215e17114437C36BCD6b8B85d8D2452fBea8
Destination chain (e.g., ethereum, avalanche, moonbeam, fantom, polygon): Avalanche
Destination chain contract address: 0x9fee1724451844198613fC6F84600A727cB2752A
Value to send in ether (e.g., 0.5 or less): 0.5
Message to send: Hello
Executing transaction for ExecutableSample...
blockHash               0x21261347224496250ca623aab4f99ccbdf27b6625a9d4c9652a248961c96f4c4
blockNumber             42074801
contractAddress
cumulativeGasUsed       651975
effectiveGasPrice       3000000016
gasUsed                 60587
logs                    [{"address":"0x0000000000000000000000000000000000001010" ...}]
logsBloom               0x..
root
status                  1
transactionHash         0x95d66b84495830b449a39e817f84abf183e333559d57f3c592b15d2dc9c1dd01
transactionIndex        9
type                    2
```

In the response above, `transactionHash` is what you need to confirm your cross-chain transaction on Axelarscan testnet [here.](https://testnet.axelarscan.io/gmp/0x95d66b84495830b449a39e817f84abf183e333559d57f3c592b15d2dc9c1dd01)
