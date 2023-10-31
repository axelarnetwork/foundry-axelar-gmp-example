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
> ⚠️ WARNING: Never commit your `PRIVATE_KEY` to any public repository or share it with anyone. Exposing your private key compromises the security of your assets and can result in loss or theft. Always keep it confidential and store it securely. If you believe your private key has been exposed, take immediate action to secure your accounts.

5. Update the .env file that was created with the preferred testnet network RPC you want to work with.

```bash
POLYGON_TESTNET_RPC_URL=
AVALANCHE_TESTNET_RPC_URL=
BINANCE_TESTNET_RPC_URL=
SCROLL_SEPOLIA_TESTNET_RPC_URL=
BASE_TESTNET_RPC_URL=
```

# Usage

The repository provides a set of `[Makefile](https://opensource.com/article/18/8/what-how-makefile)` commands to facilitate common tasks:

- `make build` : Compile the contracts.
- `make deploy` : Deploy a specific contract to a given network.
- `make format` : Format the codebase using the Foundry formatter.
- `make test` : Run tests with increased verbosity.
- `make clean` : Clean any generated artifacts.
- `make rpc` : Display RPC URLs for various networks.

# Deployment to testnet
To deploy to any of your preferred test network support in this project, you can run the command `make deploy NETWORK=network SCRIPT=script`. The `SCRIPT` parameter specifies which smart contract or script you wish to deploy to the blockchain network. Think of it as the "what" you're deploying, whereas the `NETWORK` parameter is the "where" you're deploying to.

Example:

```bash
make deploy NETWORK=polygon SCRIPT=ExecutableSample
```

The above command deploys the `ExecutableSample` contract to the Polygon Mumbai testnet. This script can also be used to target other contracts within the project.