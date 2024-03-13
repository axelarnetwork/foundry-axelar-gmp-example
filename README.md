# Foundry Axelar GMP Example

This repository showcases an example of integrating with the [Axelar GMP](https://docs.axelar.dev/dev/general-message-passing/overview) using the Foundry framework. The Foundry framework aids in deploying, testing, and interacting with smart contracts on various blockchains. This example provides a hands-on approach to demonstrate the potential and flexibility of such integrations.

In this example, the supported testnet networks are

- Ethereum
- Avalanche
- Moonbeam
- Fantom
- Polygon

Note: Additional networks can be added based on your specific needs.

# Getting Started

## Requirements

- [Foundry](https://getfoundry.sh/): Confirm installation by running `forge --version` and you should see a response like 
```bash
forge 0.2.0 (a839414 2023-10-26T09:23:16.997527000Z)
```
- [Make](https://www.gnu.org/software/make/): Confirm installation by running `make --version` and you should see a response like 
```bash
GNU Make 3.81
Copyright (C) 2006  Free Software Foundation, Inc.
This is free software; see the source for copying conditions.
There is NO warranty, not even for MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.

This program was built for i386-apple-darwin11.3.0
```

## Installation

1. Clone the repository:

```bash
git clone https://github.com/axelarnetwork/foundry-axelar-gmp-example.git
```

2. Navigate into the project directory:

```bash
cd foundry-axelar-gmp-example
```

3. Install the dependencies and build the project:

```bash
make all
```
The command above will install the required dependencies, create a `.env` file from `.env.example`, and update and build the project.


# Local

## Start the Local Chains

To get started in testing Axelar GMP locally, you need to start local chains with the following command:

```bash
make local-chain-start
```
Leave this node running on a separate terminal before deploying and testing the dApp.

## Deployment

To deploy the contracts (`ExecutableSample,` `DistributionExecutable` etc.) locally, you need to run the following command:

```bash
make local-chain-deploy
```

## Execution

### Call Contract

This example demonstrates how to relay a message from a source chain to a destination chain.

> Make sure you follow the command above to set up your local `.env` and start the local chains in a different terminal.

To execute the example, use the following command:

```
make local-chain-execute FROM={srcChain} TO={destChain} SCRIPT={script} VALUE={gasValue} MESSAGE={message}
```

#### Parameters

`srcChain`: The blockchain network from which the message will be relayed. Acceptable values include "Moonbeam", "Avalanche", "Fantom", "Ethereum", and "Polygon".

`destChain`: The blockchain network to which the message will be relayed. Acceptable values include "Moonbeam", "Avalanche", "Fantom", "Ethereum", and "Polygon".

`script`: The contract to execute on the blockchain network.

`gasValue`: The gas amount to pay for cross-chain interactions.

`message`: The message to be relayed between the chains.


#### Example

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

### Call Contract With Token

This example allows you to send aUSDC from a source chain to a destination chain and distribute it equally among specified accounts.

> Make sure you follow the command above to set up your local `.env` and start the local chains in different terminal.

To execute the example, use the following command:

```
make local-chain-execute FROM={srcChain} TO={destChain} SCRIPT={script} VALUE={gasValue} AMOUNT={amount} DEST_ADDRESSES={destinationAddresses}
```

#### Parameters

`srcChain`: The blockchain network from which the message will be relayed. Acceptable values include "Moonbeam", "Avalanche", "Fantom", "Ethereum", and "Polygon".

`destChain`: The blockchain network to which the message will be relayed. Acceptable values include "Moonbeam", "Avalanche", "Fantom", "Ethereum", and "Polygon".

`script`: The contract to execute on the blockchain network.

`gasValue`: The gas amount to pay for cross-chain interactions.

`amount`: The amount of aUSDC to be transferred and distributed among the specified accounts.

`destinationAddresses`:  The addresses to receive aUSDC.

#### Example

This example sends specified aUSDC amount from Fantom to Polygon.
```
make local-chain-execute FROM=Fantom TO=Polygon SCRIPT=DistributionExecutable VALUE=1 AMOUNT=10 DEST_ADDRESSES='["0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"]'
```

**The output will be**:
```
Using local private key for transactions...
SRC_RPC_URL: http://localhost:8548
DEST_RPC_URL: http://localhost:8549
Checking initial aUSDC balance for the account making the request...
USDC Address: 0x6f3b8e61DD1aD2d28229Ba4190554263D365D632
SRC Address: 0xe6b98F104c1BEf218F3893ADab4160Dc73Eb8367
Requesting account's address: 0x70997970C51812dc3A010C7d01b50e0d17dc79C8
Initial balance: 0
Approving USDC spend...

blockHash               0x0310a1ef6bdea1d8f3ac8060b8348c566ffcc3125bbfd42828a412e029df60c1
blockNumber             53
contractAddress
cumulativeGasUsed       46253
effectiveGasPrice       3001437507
gasUsed                 46253
logs                    [{...}]
logsBloom               0x8
root
status                  1
transactionHash         0xc40cc2469a063d87bbecadd168735e5d30771f6897d4393232e41461f1da679f
transactionIndex        0
type                    2
Approval successful.
Checking USDC allowance...

10000000 [1e7]
Executing sendToMany for DistributionExecutable...

blockHash               0x479c04b1330b8f0953eae85b48d5169f363460e00afb73c2690dbedfba234f32
blockNumber             54
contractAddress
cumulativeGasUsed       124709
effectiveGasPrice       3001258373
gasUsed                 124709
logs                    [{...}]
logsBloom               0x8
status                  1
transactionHash         0x2ef519f9cfb0ef070d9bd2d55cd077d4795376311ea4506cc62709862b94df3a
transactionIndex        0
type                    2
Transaction sent successfully.
Checking final balance for the account making the request...
Checking final aUSDC balance for the account making the request...
10000000 [1e7]
Operation completed successfully!
```


### Send Ack

Send a 2-way message from the source chain to the destination chain, and an "executed" acknowledgment is sent back to the source chain.

> Make sure you follow the command above to set up your local `.env` and start the local chains in a different terminal.

To execute the example, use the following command:

```
make local-chain-execute FROM={srcChain} TO={destChain} SCRIPT={script} VALUE={gasValue} MESSAGE={message}
```

#### Parameters

`srcChain`: The blockchain network from which the message will be relayed. Acceptable values include "Moonbeam", "Avalanche", "Fantom", "Ethereum", and "Polygon".

`destChain`: The blockchain network to which the message will be relayed. Acceptable values include "Moonbeam", "Avalanche", "Fantom", "Ethereum", and "Polygon".

`script`: The contract to execute on the blockchain network.

`gasValue`: The gas amount to pay for cross-chain interactions.

`message`: The message to be relayed between the chains.


#### Example

This example sends "Hello" from Fantom and gets an acknowledgment message "World" from Polygon.

```
make local-chain-execute FROM=Fantom TO=Polygon SCRIPT=SendAck VALUE=1 MESSAGE="Hello"
```

**The output will be**:

```
Using local private key for transactions...
SRC_RPC_URL: http://localhost:8548
DEST_RPC_URL: http://localhost:8549
Reading initial state from destination network (POLYGON)...
Message: ""
Executing sendMessage for SendAck...

blockHash               0xa9a084b37455507d18227019ee0b161acd910689f390aa025a603a9ccb7ff393
blockNumber             29
contractAddress
cumulativeGasUsed       60507
effectiveGasPrice       3030987695
gasUsed                 60507
logs                    [{...}]
logsBloom               0x
status                  1
transactionHash         0x274ddcc2f306a9e3a9ec0c82cfc210e94d360d91d32eccceebfe93075aecb1db
transactionIndex        0
type                    2
Transaction sent successfully.
Reading final state from destination network (POLYGON)...

Message: "World"
Operation completed successfully!
```

# Testnet 

Update the `TESTNET_PRIVATE_KEY` variable with your private key in your `.env`

```bash
TESTNET_PRIVATE_KEY=YOUR_KEY_HERE
```
> ⚠️ WARNING: Never commit your`TESTNET_PRIVATE_KEY` to any public repository or share it with anyone. Exposing your private key compromises the security of your assets and can result in loss or theft. Always keep it confidential and store it securely. If you believe your private key has been exposed, take immediate action to secure your accounts.


## Deployment
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

## Execution

To send a message using Axelar GMP is quite simple; what is required is to run `make execute` and pass the appropriate parameters needed, and you will be able to test the contract deployed. 

We assume you have already deployed your contract and that both source and destination chain contract addresses are available.

Let's look at an example using `ExecutableSample`; this process is similar to the other available contracts.

We have deployed `ExecutableSample` on `Polygon` here: [0xc399215e17114437C36BCD6b8B85d8D2452fBea8](https://mumbai.polygonscan.com/address/0xc399215e17114437C36BCD6b8B85d8D2452fBea8) and on `Avalanche` here: [0x9fee1724451844198613fC6F84600A727cB2752A](https://testnet.snowtrace.io/address/0x9fee1724451844198613fC6F84600A727cB2752A) for this example.

Run the following command:
```
make execute
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
Message to send: Hello World
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



# Available Tasks on the Repository

The repository provides a set of [Makefile](https://opensource.com/article/18/8/what-how-makefile) commands to facilitate common tasks:

- `make all` : Install dependencies, build, and update the project.
- `make setup-env` : Create a `.env` file from `.env.example`.
- `make install` : Install the dependencies.
- `make build` : Compile the contracts.
- `make update` : Update the project.
- `make deploy` : Deploy a specific contract to a given network.
- `make execute` : Execute a specific contract on a given network.
- `make format` : Format the codebase using the Foundry formatter.
- `make test` : Run tests with increased verbosity.
- `make clean` : Clean any generated artifacts.
- `make rpc` : Display RPC URLs for various networks.
- `make help` : Display the help menu.
- `local-chain-start`: Start the local chains
- `local-chain-deploy`: Deploy all the contracts to local chains
- `local-chain-execute`: Execute the commands to test GMP


Additionally, we have an example using Hardhat available [here.](https://github.com/axelarnetwork/axelar-examples) Check it out.