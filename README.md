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

Additionally, we have an example using Hardhat available [here.](https://github.com/axelarnetwork/axelar-examples) Check it out.

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
