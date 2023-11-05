# Include environment variables from .env file
-include .env
export

# PHONY Targets declaration
.PHONY: setup-env build deploy format test clean rpc help all install update execute

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

all: clean setup-env build

setup-env: 
	@if [ ! -f .env ]; then \
		echo "\033[0;33m⤵ Reading .env.example.\033[0m"; \
		cp .env.example .env; \
		echo "\033[0;33m⤵ Creating .env file.\033[0m"; \
		echo "\033[0;32m📨 Created .env file successfully!\033[0m"; \
	else \
		echo "\033[0;34mA .env file already exists, not modifying it.\033[0m"; \
	fi

# Install Dependencies
install:
	forge install axelarnetwork/axelar-gmp-sdk-solidity@v5.5.2 --no-commit && forge install openzeppelin/openzeppelin-contracts@v5.0.0 --no-commit && forge install foundry-rs/forge-std@v1.7.1 --no-commit

# Update Dependencies
update:
	forge update
   
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
           
# Execute the command manually after asking for user input
execute:
	@echo "Please enter the details:"; \
	read -p "Contract Name (e.g., ExecutableSample, DistributionExecutable, SendAck): " contract_name; \
	read -p "Network (e.g., polygon, avalanche, binance, scroll_sepolia, base): " network; \
	read -p "Source chain contract address: " src_address; \
	read -p "Destination chain (e.g., Polygon, Avalanche, binance, scroll, base): " dest_chain; \
	read -p "Destination chain contract address: " dest_address; \
	read -p "Value to send in ether (e.g., 0.5 for half an ether): " value_in_ether; \
	value_in_wei=$$(echo "scale=0; $$value_in_ether*10^18/1" | bc -l); \
	if [ -z "$$value_in_wei" ]; then \
		echo "\033[31mFailed to convert value to wei. Please enter a valid numeric value.\033[0m"; \
		exit 1; \
	fi; \
		if [ -z "$$network" ]; then \
		echo "\033[31mNetwork not provided. Please enter a valid network.\033[0m"; \
		exit 1; \
	fi; \
	if [ -z "$$src_address" ]; then \
		echo "\033[31mSource contract address not provided. Please enter a valid address.\033[0m"; \
		exit 1; \
	fi; \
	if [ -z "$$dest_chain" ]; then \
		echo "\033[31mDestination chain not provided. Please enter a valid destination chain.\033[0m"; \
		exit 1; \
	fi; \
	if [ -z "$$dest_address" ]; then \
		echo "\033[31mDestination contract address not provided. Please enter a valid address.\033[0m"; \
		exit 1; \
	fi; \
	if [ -z "$$value_in_ether" ]; then \
		echo "\033[31mValue in ether not provided. Please enter a valid amount.\033[0m"; \
		exit 1; \
	fi; \
	network_upper=$$(echo $$network | tr '[:lower:]' '[:upper:]'); \
	rpc_url_var=$${network_upper}_TESTNET_RPC_URL; \
	rpc_url=$${!rpc_url_var}; \
	if [ -z "$$rpc_url" ]; then \
		echo "\033[31mRPC URL for $$network is not set in .env. Please set the RPC URL for your network.\033[0m"; \
		exit 1; \
	fi; \
	if [ "$$contract_name" = "DistributionExecutable" ]; then \
		read -p "Destination addresses (comma-separated, e.g. 0x123,0x123): " dest_addresses; \
		read -p "Token symbol to send (e.g. aUSDC): " symbol; \
		read -p "Approved amount to spend: " approved_amount; \
		approved_amount_in_mwei=$$(echo "scale=0; $$approved_amount*10^6/1" | bc); \
		read -p "Amount to send: " amount; \
		amount_in_mwei=$$(echo "scale=0; $$amount*10^6/1" | bc); \
		dest_addrs_array="[$$(echo $$dest_addresses | sed 's/,/, /g')]"; \
		echo "\033[32mExecuting transaction for DistributionExecutable...\033[0m"; \
		cast send 0x2c852e740B62308c46DD29B982FBb650D063Bd07 "approve(address,uint256)" $$src_address $$approved_amount_in_mwei --rpc-url $$rpc_url --private-key $$PRIVATE_KEY && \
		echo "\033[32mApproval transaction complete, now executing sendToMany...\033[0m"; \
		cast send $$src_address "sendToMany(string,string,address[],string,uint256)" $$dest_chain $$dest_address "$$dest_addrs_array" $$symbol $$amount_in_mwei --rpc-url $$rpc_url --private-key $$PRIVATE_KEY --value $$value_in_wei || \
		echo "\033[31mTransaction failed. Please check the provided details and try again.\033[0m"; \
	else \
		read -p "Message to send: " message; \
		if [ -z "$$message" ]; then \
			echo "\033[31mMessage not provided. Please enter a valid message to send.\033[0m"; \
			exit 1; \
		fi; \
		echo "\033[32mExecuting transaction for $$contract_name...\033[0m"; \
		method_name=""; \
		if [ "$$contract_name" = "SendAck" ]; then \
			method_name="sendMessage(string,string,string)"; \
		elif [ "$$contract_name" = "ExecutableSample" ]; then \
			method_name="setRemoteValue(string,string,string)"; \
		fi; \
		if [ -n "$$method_name" ]; then \
			cast send $$src_address "$$method_name" $$dest_chain $$dest_address $$message --rpc-url $$rpc_url --private-key $$PRIVATE_KEY --value $$value_in_wei || \
			echo "\033[31mTransaction failed. Please check the provided details and try again.\033[0m"; \
		else \
			echo "\033[31mInvalid contract name. Please enter a valid contract name.\033[0m"; \
			exit 1; \
		fi; \
	fi