# Foundry Axelar GMP Example

This repository showcases an example of integrating with the [Axelar GMP](https://docs.axelar.dev/dev/general-message-passing/overview) using the Foundry framework. The Foundry framework aids in deploying, testing, and interacting with smart contracts on various blockchains. This example provides a hands-on approach to demonstrate the potential and flexibility of such integrations.

In this example, the supported testnet networks are

- Ethereum
- Avalanche
- Moonbeam
- Fantom
- Polygon

Note: Additional networks can be added based on your specific needs.

## Getting Started

### Requirements

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

- [Node](https://nodejs.org/en) version >= `18.19.0`

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

## Available Commands

The repository provides a set of Makefile commands to facilitate common tasks:

1. `make all`: Clean, set up the environment, install dependencies, and build the project.
2. `make setup-env`: Create a `.env` file from `.env.example`.
3. `make init-submodules`: Initialize and update git submodules.
4. `make install`: Install dependencies.
5. `make update`: Update dependencies.
6. `make build`: Compile the contracts.
7. `make format`: Format the codebase using the Foundry formatter.
8. `make test`: Run tests with increased verbosity.
9. `make clean`: Clean any generated artifacts.
10. `make rpc`: Display RPC URLs for various networks.
11. `make deploy`: Deploy a specific contract to a given network.
12. `make execute`: Execute a specific contract on a given network.
13. `make local-chain-start`: Start the local chains.
14. `make clean-ports`: Clean up ports used by local chains.
15. `make local-chain-deploy`: Deploy all contracts to local chains.
16. `make local-chain-execute`: Execute commands to test GMP (General Message Passing).
17. `make deploy-interchain-token`: Deploy an interchain token.
18. `make deploy-mint-burn-token-manager-and-transfer`: Set up token managers and perform a transfer.
19. `make deploy-canonical-token`: Deploy a canonical token.
20. `make help`: Display the help menu with available commands and descriptions.

## Local

### Start the Local Chains

To get started in testing Axelar GMP locally, you need to start local chains with the following command:

```bash
make local-chain-start
```

Leave this node running on a separate terminal before deploying and testing the dApp.

### Deployment

To deploy the contracts (`ExecutableSample,` `DistributionExecutable` etc.) locally, you need to run the following command:

```bash
make local-chain-deploy
```

### Execution

- [Call Contract Example](./src/call-contract)
- [Call Contract with Token Example](./src/call-contract-with-token)
- [Send Ack Example](./src/send-ack/README.md)
- [New Interchain Token Example](./src/its-interchain-token)
- [Canonical Token Deployment Example](./src/its-canonical-token)
- [Interchain Custom Token Example](./src/its-interchain-token)

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

Additionally, we have an example using Hardhat available [here.](https://github.com/axelarnetwork/axelar-examples) Check it out.
