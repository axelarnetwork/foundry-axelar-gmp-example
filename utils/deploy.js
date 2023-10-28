import { execSync } from "child_process";
import chalk from "chalk";
import dotenv from "dotenv";

dotenv.config();

const log = console.log;
const network = process.argv[2];
const script = process.argv[3];

const NETWORKS = ["polygon", "avalanche", "binance", "scroll", "base"];
const SCRIPT_MAPPINGS = {
  ExecutableSample: "script/ExecutableSample.s.sol:ExecutableSampleScript",
  DistributionExecutable:
    "script/DistributionExecutable.s.sol:DistributionExecutableScript",
  SendAck: "script/SendAck.s.sol:SendAckScript",
};

const validateInput = (input, validInputs, errorMessage) => {
  if (!validInputs.includes(input)) {
    log(chalk.red(errorMessage));
    process.exit(1);
  }
};

validateInput(
  network,
  NETWORKS,
  "Invalid network argument passed. Supported networks are: " +
    NETWORKS.join(", ")
);

validateInput(
  script,
  Object.keys(SCRIPT_MAPPINGS),
  "Invalid script argument passed. Supported scripts are: " +
    Object.keys(SCRIPT_MAPPINGS).join(", ")
);

const RPC_URLS = {
  polygon: process.env.POLYGON_TESTNET_RPC_URL,
  avalanche: process.env.AVALANCHE_TESTNET_RPC_URL,
  binance: process.env.BINANCE_TESTNET_RPC_URL,
  scroll: process.env.SCROLL_SEPOLIA_TESTNET_RPC_URL,
  base: process.env.BASE_TESTNET_RPC_URL,
};

log(chalk.cyan("Current NETWORK:", network));

const command = `NETWORK=${network} forge script ${SCRIPT_MAPPINGS[script]} --rpc-url ${RPC_URLS[network]} --broadcast --legacy`;
execSync(command, { stdio: "inherit" });

log(chalk.green("Script executed successfully!"));
