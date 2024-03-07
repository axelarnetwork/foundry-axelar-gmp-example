# Include environment variables from .env file
-include .env
export

# PHONY Targets declaration
.PHONY: setup-env build deploy format test clean rpc help all install update execute local testnet

# Supported networks and scripts
NETWORKS = ethereum avalanche moonbeam fantom polygon
SCRIPTS = ExecutableSample DistributionExecutable SendAck

# Help target - Displays available commands with descriptions
help:
	@echo "\033[0;32mAvailable targets:\033[0m"
	@echo "setup-env              - Set up the environment by creating a .env file from .env.example."
	@echo "install                - Install dependencies using the forge tool."
	@echo "build                  - Build using the forge tool." 
	@echo "update                 - Update dependencies using the forge tool."
	@echo "deploy                 - Deploy the specified script to the specified network."
	@echo "execute                - Execute the specified script manually."
	@echo "format                 - Format using the forge tool."
	@echo "test                   - Run tests using the forge tool."
	@echo "clean                  - Clean using the forge tool."
	@echo "rpc                    - Display the RPC URLs for all supported networks." 
	@echo "help                   - Display this help message."


all: clean setup-env build

setup-env: 
	@if [ ! -f .env ]; then \
		echo "\033[0;33m⤵ Reading .env.example.\033[0m"; \
		node local/script/setupEnv.js; \
		echo "\033[0;33m⤵ Creating .env file.\033[0m"; \
		echo "\033[0;32m📨 Created .env file successfully!\033[0m"; \
	else \
		echo "\033[0;34mA .env file already exists, not modifying it.\033[0m"; \
	fi

# Install Dependencies
install:
	forge install axelarnetwork/axelar-gmp-sdk-solidity@v5.5.2 --no-commit && forge install openzeppelin/openzeppelin-contracts@v5.0.0 --no-commit && forge install foundry-rs/forge-std@v1.7.1 --no-commit & npm install

# Update Dependencies
update:
	forge update
# Build target   
build:
	forge build & rm -rf artifacts && npx hardhat clean && npx hardhat compile; \

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

# Deploy target to testnet
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
           
# Execute the command manually after asking for user input
execute:
	@echo "Please enter the details:"; \
	read -p "Contract Name (e.g., ExecutableSample, DistributionExecutable, SendAck): " contract_name; \
	read -p "Network (e.g., polygon, avalanche, binance, scroll_sepolia, base): " network; \
	read -p "Source chain contract address: " src_address; \
	read -p "Destination chain (e.g., Polygon, Avalanche, binance, scroll, base): " dest_chain; \
	read -p "Destination chain contract address: " dest_address; \
	read -p "Value to send in ether (e.g., 0.5): " value_in_ether; \
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

# local targets
local-check-balance:
	@echo "Checking the balance of the account..."
	node local/script/checkBalance.js

# local chain targets
local-chain-start:
	@echo "Starting the local chain..."
	anvil > ./anvil-output.log 2>&1 &
	anvil & \
	anvil -p 8546 & \
	anvil -p 8547 & \
	anvil -p 8548 & \
	anvil -p 8549
	@echo "Anvil instances started successfully!"

start-local-script:
	@echo "Running the local script..."
	node local/script/startLocalChain.js
	@echo "Local script executed successfully!"

# Deploy all scripts to all networks
local-chain-deploy:
	@for network in $(NETWORKS); do \
		for script in $(SCRIPTS); do \
			echo "Deploying $$script to $$network..."; \
			if [ "$$script" = "ExecutableSample" ]; then \
				LOCAL_SCRIPT_PATH="script/local/ExecutableSample.s.sol:ExecutableSampleScript"; \
			elif [ "$$script" = "DistributionExecutable" ]; then \
				LOCAL_SCRIPT_PATH="script/local/DistributionExecutable.s.sol:DistributionExecutableScript"; \
			elif [ "$$script" = "SendAck" ]; then \
				LOCAL_SCRIPT_PATH="script/local/SendAck.s.sol:SendAckScript"; \
			fi; \
			RPC_URL_VAR="LOCAL_$$(echo $$network | tr a-z A-Z)_RPC_URL"; \
			RPC_URL=$${!RPC_URL_VAR}; \
			echo "RPC URL: $$RPC_URL"; \
			if [ -z "$$RPC_URL" ]; then \
				echo "Error: RPC URL is not defined for $$network."; \
				exit 1; \
			fi; \
			OUTPUT=$$(NETWORK=$$network forge script $$LOCAL_SCRIPT_PATH --rpc-url $$RPC_URL --broadcast); \
			echo "$$OUTPUT"; \
			SUCCESS_HASH=$$(echo "$$OUTPUT" | grep '\[Success\]Hash:' | awk '{print $$3}'); \
			CONTRACT_ADDRESS=$$(echo "$$OUTPUT" | grep 'Contract Address:' | awk '{print $$3}'); \
			NETWORK_UPPER=$$(echo $$network | tr '[:lower:]' '[:upper:]'); \
			SCRIPT_UPPER=$$(echo $$script | tr '[:lower:]' '[:upper:]'); \
			printf "\n\nLOCAL_$${NETWORK_UPPER}_$${SCRIPT_UPPER}_SUCCESS_HASH=$$SUCCESS_HASH\nLOCAL_$${NETWORK_UPPER}_$${SCRIPT_UPPER}_CONTRACT_ADDRESS=$$CONTRACT_ADDRESS\n" >> .env; \
			echo "$$script deployed successfully to $$network!"; \
		done; \
	done



# Determine the script path outside of the recipe
ifeq ($(SCRIPT),ExecutableSample)
LOCAL_SCRIPT_PATH=script/local/ExecutableSample.s.sol:ExecutableSampleScript
endif
ifeq ($(SCRIPT),DistributionExecutable)
LOCAL_SCRIPT_PATH=script/local/DistributionExecutable.s.sol:DistributionExecutableScript
endif
ifeq ($(SCRIPT),SendAck)
LOCAL_SCRIPT_PATH=script/local/SendAck.s.sol:SendAckScript
endif

local-chain-execute:
	@echo "Using local private key for transactions..."
	@if [ -z "$(LOCAL_PRIVATE_KEY)" ]; then \
		echo "Error: LOCAL_PRIVATE_KEY is not set."; \
		exit 1; \
	fi
	@$(eval FROM_UPPER=$(shell echo $(FROM) | tr a-z A-Z))
	@$(eval TO_UPPER=$(shell echo $(TO) | tr a-z A-Z))
	@$(eval SCRIPT_UPPER=$(shell echo $(SCRIPT) | tr a-z A-Z))
	@$(eval VALUE_IN_WEI=$(shell echo 'scale=0; $(VALUE)*10^18/1' | bc -l))
	@$(eval SRC_ADDRESS=$(shell grep "LOCAL_$(FROM_UPPER)_$(SCRIPT_UPPER)_CONTRACT_ADDRESS" .env | cut -d '=' -f2))
	@$(eval DEST_ADDRESS=$(shell grep "LOCAL_$(TO_UPPER)_$(SCRIPT_UPPER)_CONTRACT_ADDRESS" .env | cut -d '=' -f2))
	
	@$(eval RPC_URL_VAR=LOCAL_$(FROM_UPPER)_RPC_URL)
	@$(eval SRC_RPC_URL=$(shell echo $($(RPC_URL_VAR))))
	@$(eval DEST_RPC_URL_VAR=LOCAL_$(TO_UPPER)_RPC_URL)
	@$(eval DEST_RPC_URL=$(shell echo $($(DEST_RPC_URL_VAR))))
	@echo "SRC_RPC_URL: $(SRC_RPC_URL)"
	@echo "DEST_RPC_URL: $(DEST_RPC_URL)"
	
	@if [ -z "$(SRC_RPC_URL)" ] || [ -z "$(DEST_RPC_URL)" ]; then \
		echo "Error: RPC URL is not defined correctly."; \
		exit 1; \
	fi
	
	@echo "Reading initial state from destination network ($(TO_UPPER))..."
	@echo "Value: "
	@cast call $(DEST_ADDRESS) "value()(string)" --rpc-url $(DEST_RPC_URL) || echo "Failed to read initial state from destination contract."
	@echo "Source Chain: "
	@cast call $(DEST_ADDRESS) "sourceChain()(string)" --rpc-url $(DEST_RPC_URL) || echo "Failed to read initial state from destination contract."	
	@sleep 5
	
	@if [ "$(SCRIPT_UPPER)" = "EXECUTABLESAMPLE" ]; then \
		echo "Executing setRemoteValue for ExecutableSample..."; \
		cast send --rpc-url $(SRC_RPC_URL) --private-key $(LOCAL_PRIVATE_KEY) \
			$(SRC_ADDRESS) "setRemoteValue(string,string,string)" "$(TO)" "$(DEST_ADDRESS)" "$(MESSAGE)" --value $(VALUE_IN_WEI) && echo "Transaction sent successfully." || echo "Failed to send transaction."; \
	else \
		echo "Unsupported script $(SCRIPT)."; \
		exit 1; \
	fi
	
	@sleep 30
	
	@echo "Reading final state from destination network ($(TO_UPPER))..."
	@echo "Value: "
	@cast call $(DEST_ADDRESS) "value()(string)" --rpc-url $(DEST_RPC_URL) || echo "Failed to read initial state from destination contract."
	@echo "Source Chain: "
	@cast call $(DEST_ADDRESS) "sourceChain()(string)" --rpc-url $(DEST_RPC_URL) || echo "Failed to read initial state from destination contract."

	@echo "Operation completed successfully!"







