# Include environment variables from .env file
-include .env
export

# Color definitions
CYAN := \033[0;36m
YELLOW := \033[0;33m
GREEN := \033[0;32m
RED := \033[0;31m
BLUE := \033[0;34m
MAGENTA := \033[0;35m
NC := \033[0m # No Color

# PHONY Targets declaration
.PHONY: setup-env build deploy format test clean rpc help all install update execute local-chain-deploy local-chain-start local-chain-execute

# Supported networks and scripts
NETWORKS = ethereum avalanche moonbeam fantom polygon
SCRIPTS = ExecutableSample DistributionExecutable SendAck

# Help target - Displays available commands with descriptions
help:
	@echo "$(GREEN)Available targets:$(NC)"
	@echo "$(CYAN)setup-env$(NC)              - Set up the environment by creating a .env file from .env.example."
	@echo "$(CYAN)install$(NC)                - Install dependencies using the forge tool."
	@echo "$(CYAN)build$(NC)                  - Build using the forge tool."
	@echo "$(CYAN)update$(NC)                 - Update dependencies using the forge tool."
	@echo "$(CYAN)deploy$(NC)                 - Deploy the specified script to the specified network."
	@echo "$(CYAN)execute$(NC)                - Execute the specified script manually."
	@echo "$(CYAN)format$(NC)                 - Format using the forge tool."
	@echo "$(CYAN)test$(NC)                   - Run tests using the forge tool."
	@echo "$(CYAN)clean$(NC)                  - Clean using the forge tool."
	@echo "$(CYAN)rpc$(NC)                    - Display the RPC URLs for all supported networks."
	@echo "$(CYAN)help$(NC)                   - Display this help message."

all: clean setup-env install build

setup-env:
	@if [ ! -f .env ]; then \
		echo "$(YELLOW)⤵ Reading .env.example.$(NC)"; \
		node local/script/setupEnv.js; \
		echo "$(YELLOW)⤵ Creating .env file.$(NC)"; \
		echo "$(GREEN)📨 Created .env file successfully!$(NC)"; \
	else \
		echo "$(BLUE)A .env file already exists, not modifying it.$(NC)"; \
	fi

# Install Dependencies
install:
	@echo "$(YELLOW)Installing dependencies...$(NC)"
	@forge install axelarnetwork/axelar-gmp-sdk-solidity@v5.5.2 --no-commit && forge install openzeppelin/openzeppelin-contracts@v5.0.0 --no-commit && forge install foundry-rs/forge-std@v1.7.1 --no-commit & npm install
	@echo "$(GREEN)Dependencies installed successfully!$(NC)"

# Update Dependencies
update:
	@echo "$(YELLOW)Updating dependencies...$(NC)"
	@forge update
	@echo "$(GREEN)Dependencies updated successfully!$(NC)"

# Build target
build:
	@echo "$(YELLOW)Building project...$(NC)"
	@forge build && rm -rf artifacts && npx hardhat clean && npx hardhat compile
	@echo "$(GREEN)Build completed successfully!$(NC)"

# Format target
format:
	@echo "$(YELLOW)Formatting code...$(NC)"
	@forge fmt
	@echo "$(GREEN)Formatting completed successfully!$(NC)"

# Test target
test:
	@echo "$(YELLOW)Running tests...$(NC)"
	@forge test -vvv
	@echo "$(GREEN)Tests completed successfully!$(NC)"

# Clean target
clean:
	@echo "$(YELLOW)Cleaning project...$(NC)"
	@forge clean
	@echo "$(GREEN)Clean completed successfully!$(NC)"

# Display RPC URLs
rpc:
	@echo "$(GREEN)Polygon RPC URL:$(NC)" $(ETHEREUM_TESTNET_RPC_URL)
	@echo "$(BLUE)Avalanche RPC URL:$(NC)" $(AVALANCHE_TESTNET_RPC_URL)
	@echo "$(MAGENTA)Binance RPC URL:$(NC)" $(MOONBEAM_TESTNET_RPC_URL)
	@echo "$(CYAN)Scroll RPC URL:$(NC)" $(FANTOM_TESTNET_RPC_URL)
	@echo "$(YELLOW)Base RPC URL:$(NC)" $(POLYGON_TESTNET_RPC_URL)

# Determine the script path outside of the recipe
ifeq ($(SCRIPT),ExecutableSample)
SCRIPT_PATH=script/testnet/ExecutableSample.s.sol:ExecutableSampleScript
endif
ifeq ($(SCRIPT),DistributionExecutable)
SCRIPT_PATH=script/testnet/DistributionExecutable.s.sol:DistributionExecutableScript
endif
ifeq ($(SCRIPT),SendAck)
SCRIPT_PATH=script/testnet/SendAck.s.sol:SendAckScript
endif

# Deploy target to testnet
deploy:
ifndef NETWORK
	@echo "$(RED)Error: NETWORK is undefined. Supported networks are: $(NETWORKS)$(NC)"
	@exit 1
endif
ifndef SCRIPT
	@echo "$(RED)Error: SCRIPT is undefined. Supported scripts are: $(SCRIPTS)$(NC)"
	@exit 1
endif
ifneq ($(findstring $(NETWORK),$(NETWORKS)), $(NETWORK))
	@echo "$(RED)Error: Invalid network argument passed. Supported networks are: $(NETWORKS)$(NC)"
	@exit 1
endif
ifneq ($(findstring $(SCRIPT),$(SCRIPTS)), $(SCRIPT))
	@echo "$(RED)Error: Invalid script argument passed. Supported scripts are: $(SCRIPTS)$(NC)"
	@exit 1
endif
	@echo "$(YELLOW)Current NETWORK: $(NETWORK)$(NC)"
	@NETWORK=$(NETWORK) forge script $(SCRIPT_PATH) --rpc-url $($(shell echo $(NETWORK) | tr a-z A-Z)_TESTNET_RPC_URL) --broadcast --legacy
	@echo "$(GREEN)Script executed successfully!$(NC)"

# Execute the command manually after asking for user input
execute:
	@echo "$(YELLOW)Please enter the details:$(NC)"; \
	read -p "Contract Name (e.g., ExecutableSample, DistributionExecutable, SendAck): " contract_name; \
	read -p "Source Chain Network (e.g., ethereum, avalanche, moonbeam, fantom, polygon): " network; \
	read -p "Source chain contract address: " src_address; \
	read -p "Destination Chain Network (e.g., ethereum-sepolia, Avalanche, Moonbeam, Fantom, Polygon): " dest_chain; \
	read -p "Destination chain contract address: " dest_address; \
	read -p "Value to send in ether (e.g., 0.5): " value_in_ether; \
	value_in_wei=$$(echo "scale=0; $$value_in_ether*10^18/1" | bc -l); \
	if [ -z "$$value_in_wei" ]; then \
		echo "$(RED)Failed to convert value to wei. Please enter a valid numeric value.$(NC)"; \
		exit 1; \
	fi; \
	if [ -z "$$network" ]; then \
		echo "$(RED)Network not provided. Please enter a valid network.$(NC)"; \
		exit 1; \
	fi; \
	if [ -z "$$src_address" ]; then \
		echo "$(RED)Source contract address not provided. Please enter a valid address.$(NC)"; \
		exit 1; \
	fi; \
	if [ -z "$$dest_chain" ]; then \
		echo "$(RED)Destination chain not provided. Please enter a valid destination chain.$(NC)"; \
		exit 1; \
	fi; \
	if [ -z "$$dest_address" ]; then \
		echo "$(RED)Destination contract address not provided. Please enter a valid address.$(NC)"; \
		exit 1; \
	fi; \
	if [ -z "$$value_in_ether" ]; then \
		echo "$(RED)Value in ether not provided. Please enter a valid amount.$(NC)"; \
		exit 1; \
	fi; \
	network_upper=$$(echo $$network | tr '[:lower:]' '[:upper:]'); \
	rpc_url_var=$${network_upper}_TESTNET_RPC_URL; \
	rpc_url=$${!rpc_url_var}; \
	if [ -z "$$rpc_url" ]; then \
		echo "$(RED)RPC URL for $$network is not set in .env. Please set the RPC URL for your network.$(NC)"; \
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
		echo "$(YELLOW)Executing transaction for DistributionExecutable...$(NC)"; \
		cast send 0x2c852e740B62308c46DD29B982FBb650D063Bd07 "approve(address,uint256)" $$src_address $$approved_amount_in_mwei --rpc-url $$rpc_url --private-key $$TESTNET_PRIVATE_KEY && \
		echo "$(GREEN)Approval transaction complete, now executing sendToMany...$(NC)"; \
		cast send $$src_address "sendToMany(string,string,address[],string,uint256)" $$dest_chain $$dest_address "$$dest_addrs_array" $$symbol $$amount_in_mwei --rpc-url $$rpc_url --private-key $$TESTNET_PRIVATE_KEY --value $$value_in_wei || \
		echo "$(RED)Transaction failed. Please check the provided details and try again.$(NC)"; \
	else \
		read -p "Message to send: " message; \
		if [ -z "$$message" ]; then \
			echo "$(RED)Message not provided. Please enter a valid message to send.$(NC)"; \
			exit 1; \
		fi; \
		echo "$(YELLOW)Executing transaction for $$contract_name...$(NC)"; \
		method_name=""; \
		if [ "$$contract_name" = "SendAck" ]; then \
			method_name="sendMessage(string,string,string)"; \
		elif [ "$$contract_name" = "ExecutableSample" ]; then \
			method_name="setRemoteValue(string,string,string)"; \
		fi; \
		if [ -n "$$method_name" ]; then \
			cast send $$src_address "$$method_name" $$dest_chain $$dest_address $$message --rpc-url $$rpc_url --private-key $$TESTNET_PRIVATE_KEY --value $$value_in_wei || \
			echo "$(RED)Transaction failed. Please check the provided details and try again.$(NC)"; \
		else \
			echo "$(RED)Invalid contract name. Please enter a valid contract name.$(NC)"; \
			exit 1; \
		fi; \
	fi

# local chain targets
local-chain-start:
	@echo "$(YELLOW)Starting the local chain...$(NC)"
	anvil &
	anvil -p 8546 &
	anvil -p 8547 &
	anvil -p 8548 &
	anvil -p 8549 &
	sleep 10; \
	node local/script/startLocalChain.js
	@echo "$(GREEN)Local script executed successfully!$(NC)"

local-chain-deploy:
	@for network in $(NETWORKS); do \
		for script in $(SCRIPTS); do \
			echo "$(YELLOW)Deploying $$script to $$network...$(NC)"; \
			if [ "$$script" = "ExecutableSample" ]; then \
				LOCAL_SCRIPT_PATH="script/local/ExecutableSample.s.sol:ExecutableSampleScript"; \
			elif [ "$$script" = "DistributionExecutable" ]; then \
				LOCAL_SCRIPT_PATH="script/local/DistributionExecutable.s.sol:DistributionExecutableScript"; \
			elif [ "$$script" = "SendAck" ]; then \
				LOCAL_SCRIPT_PATH="script/local/SendAck.s.sol:SendAckScript"; \
			fi; \
			RPC_URL_VAR="LOCAL_$$(echo $$network | tr a-z A-Z)_RPC_URL"; \
			RPC_URL=$${!RPC_URL_VAR}; \
			echo "$(BLUE)RPC URL: $$RPC_URL$(NC)"; \
			if [ -z "$$RPC_URL" ]; then \
				echo "$(RED)Error: RPC URL is not defined for $$network.$(NC)"; \
				exit 1; \
			fi; \
			OUTPUT=$$(NETWORK=$$network forge script $$LOCAL_SCRIPT_PATH --rpc-url $$RPC_URL --broadcast); \
			echo "$$OUTPUT"; \
			SUCCESS_HASH=$$(echo "$$OUTPUT" | grep '\[Success\]Hash:' | awk '{print $$3}'); \
			CONTRACT_ADDRESS=$$(echo "$$OUTPUT" | grep 'Contract Address:' | awk '{print $$3}'); \
			NETWORK_UPPER=$$(echo $$network | tr '[:lower:]' '[:upper:]'); \
			SCRIPT_UPPER=$$(echo $$script | tr '[:lower:]' '[:upper:]'); \
			KEY_HASH="LOCAL_$${NETWORK_UPPER}_$${SCRIPT_UPPER}_SUCCESS_HASH"; \
			KEY_ADDRESS="LOCAL_$${NETWORK_UPPER}_$${SCRIPT_UPPER}_CONTRACT_ADDRESS"; \
			if grep -q $$KEY_HASH .env; then \
				sed -i'.bak' "s/^$${KEY_HASH}=.*$$/$${KEY_HASH}=$$SUCCESS_HASH/" .env && rm .env.bak; \
			else \
				echo "" >> .env && echo "$${KEY_HASH}=$$SUCCESS_HASH" >> .env; \
			fi; \
			if grep -q $$KEY_ADDRESS .env; then \
				sed -i'.bak' "s/^$${KEY_ADDRESS}=.*$$/$${KEY_ADDRESS}=$$CONTRACT_ADDRESS/" .env && rm .env.bak; \
			else \
				echo "" >> .env && echo "$${KEY_ADDRESS}=$$CONTRACT_ADDRESS" >> .env; \
			fi; \
			echo "$(GREEN)$$script deployed successfully to $$network!$(NC)"; \
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
	@echo "$(YELLOW)Using local private key for transactions...$(NC)"
	@if [ -z "$(LOCAL_PRIVATE_KEY)" ]; then \
		echo "$(RED)Error: LOCAL_PRIVATE_KEY is not set.$(NC)"; \
		exit 1; \
	fi
	$(eval FROM_UPPER=$(shell echo $(FROM) | tr a-z A-Z))
	$(eval TO_UPPER=$(shell echo $(TO) | tr a-z A-Z))
	$(eval SCRIPT_UPPER=$(shell echo $(SCRIPT) | tr a-z A-Z))
	$(eval VALUE_IN_WEI=$(shell echo 'scale=0; $(VALUE)*10^18/1' | bc -l))
	$(eval SRC_ADDRESS=$(shell grep "LOCAL_$(FROM_UPPER)_$(SCRIPT_UPPER)_CONTRACT_ADDRESS" .env | cut -d '=' -f2))
	$(eval DEST_ADDRESS=$(shell grep "LOCAL_$(TO_UPPER)_$(SCRIPT_UPPER)_CONTRACT_ADDRESS" .env | cut -d '=' -f2))

	$(eval RPC_URL_VAR=LOCAL_$(FROM_UPPER)_RPC_URL)
	$(eval SRC_RPC_URL=$(shell echo $($(RPC_URL_VAR))))
	$(eval DEST_RPC_URL_VAR=LOCAL_$(TO_UPPER)_RPC_URL)
	$(eval DEST_RPC_URL=$(shell echo $($(DEST_RPC_URL_VAR))))
	@echo "$(BLUE)SRC_RPC_URL: $(SRC_RPC_URL)$(NC)"
	@echo "$(BLUE)DEST_RPC_URL: $(DEST_RPC_URL)$(NC)"

	@if [ -z "$(SRC_RPC_URL)" ] || [ -z "$(DEST_RPC_URL)" ]; then \
		echo "$(RED)Error: RPC URL is not defined correctly.$(NC)"; \
		exit 1; \
	fi

	@if [ "$(SCRIPT_UPPER)" = "EXECUTABLESAMPLE" ]; then \
		echo "$(YELLOW)Reading initial state from destination network ($(TO_UPPER))...$(NC)"; \
		echo "$(CYAN)Value: $(NC)"; \
		cast call $(DEST_ADDRESS) "value()(string)" --rpc-url $(DEST_RPC_URL) || echo "$(RED)Failed to read initial state from destination contract.$(NC)"; \
		echo "$(CYAN)Source Chain: $(NC)"; \
		cast call $(DEST_ADDRESS) "sourceChain()(string)" --rpc-url $(DEST_RPC_URL) || echo "$(RED)Failed to read initial state from destination contract.$(NC)"; \
		echo "$(YELLOW)Executing setRemoteValue for ExecutableSample...$(NC)"; \
		sleep 5; \
		cast send --rpc-url $(SRC_RPC_URL) --private-key $(LOCAL_PRIVATE_KEY) \
			$(SRC_ADDRESS) "setRemoteValue(string,string,string)" "$(TO)" "$(DEST_ADDRESS)" "$(MESSAGE)" --value $(VALUE_IN_WEI) && echo "$(GREEN)Transaction sent successfully.$(NC)" || echo "$(RED)Failed to send transaction.$(NC)"; \
		echo "$(YELLOW)Reading final state from destination network ($(TO_UPPER))...$(NC)"; \
		sleep 10; \
		echo "$(CYAN)Value: $(NC)"; \
		cast call $(DEST_ADDRESS) "value()(string)" --rpc-url $(DEST_RPC_URL) || echo "$(RED)Failed to read final state from destination contract.$(NC)"; \
		echo "$(CYAN)Source Chain: $(NC)"; \
		cast call $(DEST_ADDRESS) "sourceChain()(string)" --rpc-url $(DEST_RPC_URL) || echo "$(RED)Failed to read final state from destination contract.$(NC)"; \
	elif [ "$(SCRIPT_UPPER)" = "SENDACK" ]; then \
		echo "$(YELLOW)Reading initial state from destination network ($(TO_UPPER))...$(NC)"; \
		echo "$(CYAN)Message: $(NC)"; \
		cast call $(DEST_ADDRESS) "message()(string)" --rpc-url $(DEST_RPC_URL) || echo "$(RED)Failed to read initial state from destination contract.$(NC)"; \
		echo "$(YELLOW)Executing sendMessage for SendAck...$(NC)"; \
		sleep 5; \
		cast send --rpc-url $(SRC_RPC_URL) --private-key $(LOCAL_PRIVATE_KEY) \
			$(SRC_ADDRESS) "sendMessage(string,string,string)" "$(TO)" "$(DEST_ADDRESS)" "$(MESSAGE)" --value $(VALUE_IN_WEI) && echo "$(GREEN)Transaction sent successfully.$(NC)" || echo "$(RED)Failed to send transaction.$(NC)"; \
		echo "$(YELLOW)Reading final state from destination network ($(TO_UPPER))...$(NC)"; \
		sleep 10; \
		echo "$(CYAN)Message: $(NC)"; \
		cast call $(DEST_ADDRESS) "message()(string)" --rpc-url $(SRC_RPC_URL) || echo "$(RED)Failed to read final state from destination contract.$(NC)"; \
	elif [ "$(SCRIPT_UPPER)" = "DISTRIBUTIONEXECUTABLE" ]; then \
		echo "$(YELLOW)Checking initial aUSDC balance for the account making the request...$(NC)"; \
		$(eval USDC_ADDRESS_VAR=LOCAL_$(FROM_UPPER)_USDC_ADDRESS) \
		$(eval USDC_ADDRESS=$(shell echo $($(USDC_ADDRESS_VAR)))) \
		$(eval ADDRESS_VAR=ADDRESS) \
		$(eval ADDRESS=$(shell grep "$(ADDRESS_VAR)" .env | cut -d '=' -f2)) \
		echo "$(CYAN)USDC Address: $(USDC_ADDRESS)$(NC)"; \
		echo "$(CYAN)SRC Address: $(SRC_ADDRESS)$(NC)"; \
		echo "$(CYAN)Requesting account's address: $(LOCAL_ADDRESS)$(NC)"; \
		$(eval BALANCE_BEFORE=$(shell cast call $(USDC_ADDRESS) "balanceOf(address)(uint256)" "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266" --rpc-url $(DEST_RPC_URL))) \
		echo "$(CYAN)Initial balance: $${BALANCE_BEFORE}$(NC)"; \
		echo "$(YELLOW)Approving USDC spend...$(NC)"; \
		sleep 5; \
		$(eval AMOUNT_IN_SMALLEST_UNIT=$(shell echo '$(AMOUNT)*10^6' | bc)) \
		cast send --rpc-url $(SRC_RPC_URL) --private-key $(LOCAL_PRIVATE_KEY) \
			--gas-limit 100000 "$(USDC_ADDRESS)" "approve(address,uint256)" \
			"$(SRC_ADDRESS)" "$(AMOUNT_IN_SMALLEST_UNIT)" && echo "$(GREEN)Approval successful.$(NC)" || echo "$(RED)Failed to approve USDC spend.$(NC)"; \
		echo "$(YELLOW)Checking USDC allowance...$(NC)"; \
		sleep 5; \
		cast call $(USDC_ADDRESS) "allowance(address,address)(uint256)" "$(LOCAL_ADDRESS)" "$(SRC_ADDRESS)" --rpc-url $(SRC_RPC_URL); \
		echo "$(YELLOW)Executing sendToMany for DistributionExecutable...$(NC)"; \
		sleep 5; \
		$(eval AMOUNT_IN_WEI=$(shell echo '$(AMOUNT)*10^6' | bc)) \
		cast send --rpc-url $(SRC_RPC_URL) --private-key $(LOCAL_PRIVATE_KEY) \
			$(SRC_ADDRESS) "sendToMany(string,string,address[],string,uint256)" \
			"$(TO)" "$(DEST_ADDRESS)" "$(DEST_ADDRESSES)" "aUSDC" "$(AMOUNT_IN_WEI)" \
			--value $(VALUE_IN_WEI) && echo "$(GREEN)Transaction sent successfully.$(NC)" || echo "$(RED)Failed to send transaction.$(NC)"; \
		echo "$(YELLOW)Checking final balance for the account making the request...$(NC)"; \
		sleep 10; \
		echo "$(YELLOW)Checking final aUSDC balance for the account making the request...$(NC)"; \
		cast call $(USDC_ADDRESS) "balanceOf(address)(uint256)" "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266" --rpc-url $(DEST_RPC_URL) || echo "$(RED)Failed to read initial balance from USDC contract.$(NC)"; \
	else \
		echo "$(RED)Unsupported script $(SCRIPT).$(NC)"; \
		exit 1; \
	fi

	@echo "$(GREEN)Operation completed successfully!$(NC)"

# Interchain Token Service
# Deploy Interchain Token
deploy-interchain-token:
	@echo "$(YELLOW)Deploying Interchain Token...$(NC)"
	@read -p "Enter network (ethereum, avalanche, moonbeam, fantom, polygon): " network; \
	read -p "Enter token name: " token_name; \
	read -p "Enter token symbol: " token_symbol; \
	read -p "Enter token decimals: " token_decimals; \
	read -p "Enter initial token amount: " token_amount; \
	network_upper=$$(echo $$network | tr '[:lower:]' '[:upper:]'); \
	rpc_url_var="LOCAL_$${network_upper}_RPC_URL"; \
	rpc_url=$${!rpc_url_var}; \
	if [ -z "$$rpc_url" ]; then \
		echo "$(RED)Error: RPC URL for $$network is not set in .env. Please set the RPC URL for your network.$(NC)"; \
		exit 1; \
	fi; \
	echo "$(CYAN)Debug: Network: $$network$(NC)"; \
	echo "$(CYAN)Debug: Network (uppercase): $$network_upper$(NC)"; \
	echo "$(CYAN)Debug: RPC URL: $$rpc_url$(NC)"; \
	echo "$(CYAN)Debug: Token Name: $$token_name$(NC)"; \
	echo "$(CYAN)Debug: Token Symbol: $$token_symbol$(NC)"; \
	echo "$(CYAN)Debug: Token Decimals: $$token_decimals$(NC)"; \
	echo "$(CYAN)Debug: Token Amount: $$token_amount$(NC)"; \
	script_path="script/local/InterchainToken.s.sol"; \
	echo "$(CYAN)Debug: Script path: $$script_path$(NC)"; \
	NETWORK=$$network_upper \
	TOKEN_NAME=$$token_name \
	TOKEN_SYMBOL=$$token_symbol \
	TOKEN_DECIMALS=$$token_decimals \
	TOKEN_AMOUNT=$$token_amount \
	forge script $$script_path:InterchainTokenScript \
		--rpc-url $$rpc_url \
		--broadcast \
		-vvvv || { echo "$(RED)Error: Forge script execution failed$(NC)"; exit 1; }
	@echo "$(GREEN)Interchain Token deployment completed!$(NC)"