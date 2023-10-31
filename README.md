# Foundry Axelar GMP Example

This repository showcases an example of integrating with the Axelar GMP using the Foundry framework. The Foundry framework aids in deploying, testing, and interacting with smart contracts on various blockchains. This example provides a hands-on approach to demonstrate the potential and flexibility of such integrations.

In this example, the supported testnet networks are `polygon, avalanche, binance, scroll_sepolia, base.` Feel free to add your based on your needs.

# Getting Started

## Requirements

- [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git): Confirm installation by running `git --version`, and you should see a response like `git version x.x.x`
- [Foundry](https://getfoundry.sh/): Confirm installation by running `forge --version` and you should see a response like `forge 0.2.0 (a839414 2023-10-26T09:23:16.997527000Z)`

## Installation

1. Clone the repository:

```bash
git clone https://github.com/Olanetsoft/foundry-axelar-gmp-example.git
```

2. Navigate into the project directory:

```bash
cd foundry-axelar-gmp-example
```

3. Install the dependencies:

```bash
make all
```
The command above will install the required dependencies, create a `.env` file from `.env.example`, and update and build the project.

4. Update the PRIVATE_KEY variable with your private key

```bash
PRIVATE_KEY=<your-private-key-here>
```

5. Update the .env file that was created with the preferred testnet network RPC you want to work with.
6. 
```bash
POLYGON_TESTNET_RPC_URL=
AVALANCHE_TESTNET_RPC_URL=
BINANCE_TESTNET_RPC_URL=
SCROLL_SEPOLIA_TESTNET_RPC_URL=
BASE_TESTNET_RPC_URL=
```

# Usage

The repository provides a set of Makefile commands to facilitate common tasks:

- `make build` : Compile the contracts.
- `make deploy` : Deploy a specific contract to a given network.
- `make format` : Format the codebase using the Foundry formatter.
- `make test` : Run tests with increased verbosity.
- `make clean` : Clean any generated artifacts.
- `make rpc` : Display RPC URLs for various networks.

# Deployment to testnet
To deploy to any of your preferred test network support in this project, you can run the command `make deploy NETWORK=network SCRIPT=script`. e.g.:

```bash
make deploy NETWORK=polygon SCRIPT=ExecutableSample
```

The command above will deploy to the Polygon Mumbai testnet successfully.
