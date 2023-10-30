# Include environment variables from .env file
-include .env
export

# PHONY Targets declaration
.PHONY: setup-env build deploy format test clean rpc

# Supported networks and scripts
NETWORKS = polygon avalanche binance scroll_sepolia base
SCRIPTS = ExecutableSample DistributionExecutable SendAck

# Help target - Displays available commands with descriptions
help:
	@echo "\033[0;32mAvailable targets:\033[0m"
	@echo "setup-env              - Set up the environment by creating a .env file from .env.example."
	@echo "build                  - Build using the forge tool."
	@echo "deploy                 - Deploy the specified script to the specified network."
	@echo "format                 - Format using the forge tool."
	@echo "test                   - Run tests using the forge tool."
	@echo "clean                  - Clean using the forge tool."
	@echo "rpc                    - Display the RPC URLs for all supported networks."
	@echo "help                   - Display this help message."

setup-env:
	@if [ ! -f .env ]; then \
		echo "\033[0;33m⤵ Reading .env.example.\033[0m"; \
		cp .env.example .env; \
		echo "\033[0;33m⤵ Creating .env file.\033[0m"; \
		echo "\033[0;32m📨 Created .env file successfully!\033[0m"; \
	else \
		echo "\033[0;34mA .env file already exists, not modifying it.\033[0m"; \
	fi

# Build target
build:
	@forge build

# Determine the script path outside of the recipe
ifeq ($(SCRIPT),ExecutableSample)
SCRIPT_PATH=script/ExecutableSample.s.sol:ExecutableSampleScript
endif
ifeq ($(SCRIPT),DistributionExecutable)
SCRIPT_PATH=script/DistributionExecutable.s.sol:DistributionExecutableScript
endif
ifeq ($(SCRIPT),SendAck)
SCRIPT_PATH=script/SendAck.s.sol:SendAckScript
endif

# Deploy target
deploy:
ifndef NETWORK
	$(error NETWORK is undefined. Supported networks are: $(NETWORKS))
endif
ifndef SCRIPT
	$(error SCRIPT is undefined. Supported scripts are: $(SCRIPTS))
endif
ifneq ($(findstring $(NETWORK),$(NETWORKS)), $(NETWORK))
	$(error Invalid network argument passed. Supported networks are: $(NETWORKS))
endif
ifneq ($(findstring $(SCRIPT),$(SCRIPTS)), $(SCRIPT))
	$(error Invalid script argument passed. Supported scripts are: $(SCRIPTS))
endif
	@echo "Current NETWORK: $(NETWORK)"
	@NETWORK=$(NETWORK) forge script $(SCRIPT_PATH) --rpc-url $($(shell echo $(NETWORK) | tr a-z A-Z)_TESTNET_RPC_URL) --broadcast --legacy
	@echo "Script executed successfully!"

# Format target
format:
	@forge fmt

# Test target
test:
	@forge test -vvv

# Clean target
clean:
	@:; forge clean

# Display RPC URLs
rpc:
	@echo "\033[0;32mPolygon RPC URL:\033[0m" $(POLYGON_TESTNET_RPC_URL)     
	@echo "\033[0;34mAvalanche RPC URL:\033[0m" $(AVALANCHE_TESTNET_RPC_URL) 
	@echo "\033[0;35mBinance RPC URL:\033[0m" $(BINANCE_TESTNET_RPC_URL)     
	@echo "\033[0;36mScroll RPC URL:\033[0m" $(SCROLL_SEPOLIA_TESTNET_RPC_URL)       
	@echo "\033[0;33mBase RPC URL:\033[0m" $(BASE_TESTNET_RPC_URL)          
