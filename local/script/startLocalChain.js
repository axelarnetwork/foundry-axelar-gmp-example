import { setupAndExport } from "@axelar-network/axelar-local-dev";
import { promises as fs } from "fs";
import { ethers } from "ethers";

const ENV_FILE_PATH = ".env";
const TO_FUND = ["0x70997970C51812dc3A010C7d01b50e0d17dc79C8"];
const CHAINS = [
  { name: "Ethereum", rpcUrl: "http://localhost:8545" },
  { name: "Avalanche", rpcUrl: "http://localhost:8546" },
  { name: "Moonbeam", rpcUrl: "http://localhost:8547" },
  { name: "Fantom", rpcUrl: "http://localhost:8548" },
  { name: "Polygon", rpcUrl: "http://localhost:8549" },
];

async function loadEnvFile(filePath) {
  try {
    const data = await fs.readFile(filePath, { encoding: "utf8" });
    return Object.fromEntries(
      data
        .split("\n")
        .map((line) => line.split("="))
        .filter(([key, value]) => key && value)
        .map(([key, value]) => [key.trim(), value.trim()])
    );
  } catch (error) {
    if (error.code === "ENOENT") {
      console.log(".env file does not exist, creating a new one.");
      return {};
    }
    throw error;
  }
}

async function saveEnvFile(filePath, data) {
  const envContent = Object.entries(data)
    .map(([key, value]) => `${key}=${value}`)
    .join("\n");
  await fs.writeFile(filePath, envContent, { encoding: "utf8" });
}

async function updateEnvData(chain, data, envData) {
  const prefix = data.name.toUpperCase();
  const updates = {
    [`LOCAL_${prefix}_GATEWAY_ADDRESS`]: data.gatewayAddress,
    [`LOCAL_${prefix}_GAS_RECEIVER_ADDRESS`]: data.gasReceiverAddress,
    [`LOCAL_${prefix}_RPC_URL`]: data.rpc,
    [`LOCAL_${prefix}_INTERCHAIN_TOKEN_SERVICE`]: data.InterchainTokenService,
    [`LOCAL_${prefix}_INTERCHAIN_TOKEN_FACTORY`]: data.InterchainTokenFactory,
  };

  chain.usdc = await chain.deployToken(
    "Axelar Wrapped USDC",
    "aUSDC",
    6,
    ethers.utils.parseEther("1000")
  );
  updates[`LOCAL_${prefix}_USDC_ADDRESS`] = chain.usdc.address;

  for (const address of TO_FUND) {
    await chain.giveToken(address, "aUSDC", ethers.utils.parseUnits("200", 6));
  }

  return { ...envData, ...updates };
}

async function main() {
  try {
    const envData = await loadEnvFile(ENV_FILE_PATH);

    await setupAndExport({
      chains: CHAINS,
      relayInterval: 5000,
      callback: async (chain, data) => {
        Object.assign(envData, await updateEnvData(chain, data, envData));
      },
    });

    await saveEnvFile(ENV_FILE_PATH, envData);
    console.log("Chain data saved or updated in .env");
  } catch (error) {
    console.error("Error:", error);
  }
}

main();
