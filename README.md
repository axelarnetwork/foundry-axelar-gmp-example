# Foundry Axelar GMP Example

This repository showcases an example of integrating with the [Axelar GMP](https://docs.axelar.dev/dev/general-message-passing/overview) using the Foundry framework. The Foundry framework aids in deploying, testing, and interacting with smart contracts on various blockchains. This example provides a hands-on approach to demonstrate the potential and flexibility of such integrations.

In this example, the supported testnet networks are

- Polygon
- Avalanche
- Binance
- Scroll Sepolia
- Base

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

This program built for i386-apple-darwin11.3.0
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

4. Update the PRIVATE_KEY variable with your private key

```bash
PRIVATE_KEY=<your-private-key-here>
```
> ⚠️ WARNING: Never commit your `PRIVATE_KEY` to any public repository or share it with anyone. Exposing your private key compromises the security of your assets and can result in loss or theft. Always keep it confidential and store it securely. If you believe your private key has been exposed, take immediate action to secure your accounts.


# Usage

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

# Deployment to testnet
To deploy to any of your preferred test networks this project supports, ensure you have tokens from a faucet for the respective network. You can acquire faucet tokens for the Polygon Mumbai testnet [here](https://faucet.polygon.technology/), for Avalanche [here](https://docs.avax.network/build/dapp/smart-contracts/get-funds-faucet), and for Scroll Sepolia [here](https://docs.scroll.io/en/user-guide/faucet/). For Binance, faucet tokens can be obtained on their Discord server, and for [Base](https://www.coinbase.com/faucets/base-ethereum-goerli-faucet), use this link. Make sure that these tokens are in the account linked to the private key you have provided in your `.env` file.


Next, run the following command. 

```bash
make deploy NETWORK=network SCRIPT=script
``` 
The `SCRIPT` parameter specifies which smart contract or script you wish to deploy to the blockchain network. Think of it as the "what" you're deploying, whereas the `NETWORK` parameter is the "where" you're deploying to.

Example:

```bash
make deploy NETWORK=polygon SCRIPT=ExecutableSample
```
The above command deploys the `ExecutableSample` contract to the Polygon Mumbai testnet. This script can also be used to target other contracts within the project.

# Testing send message functionality using Axelar GMP 

To send a message using Axelar GMP is quite simple; what is required is to run `make execute` and pass the appropriate parameters needed, and you will be able to test the contract deployed. We assume you have already deployed your contract and have both source and destination chain contract addresses available.

Let's look at an example using `ExecutableSample`; this is a similar process for the other available contracts.

We have deployed `ExecutableSample` on `Polygon` here: [0xc399215e17114437C36BCD6b8B85d8D2452fBea8](https://mumbai.polygonscan.com/address/0xc399215e17114437C36BCD6b8B85d8D2452fBea8) and on `Avalanche` here: [0x9fee1724451844198613fC6F84600A727cB2752A](https://testnet.snowtrace.io/address/0x9fee1724451844198613fC6F84600A727cB2752A) for this example.

Run
```
make execute
```
You should get the following response similar to what we have below if you are also testing with the `ExecutableSample` contract.
```
Please enter the details:
Contract Name (e.g., ExecutableSample, DistributionExecutable, SendAck): ExecutableSample
Network (e.g., polygon, avalanche, binance, scroll_sepolia, base): polygon
Source chain contract address: 0xc399215e17114437C36BCD6b8B85d8D2452fBea8
Destination chain (e.g., Polygon, Avalanche, binance, scroll, base): Avalanche
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
