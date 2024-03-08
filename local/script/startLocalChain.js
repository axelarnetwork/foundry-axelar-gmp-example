import { setupAndExport } from "@axelar-network/axelar-local-dev";
import { promises as fs } from "fs";

(async () => {
  const envFilePath = ".env"; // Path to your .env file

  // Function to load the existing .env file or initialize a new object if it doesn't exist
  async function loadEnvFile(filePath) {
    try {
      const data = await fs.readFile(filePath, { encoding: "utf8" });
      return data.split("\n").reduce((acc, line) => {
        const [key, value] = line.split("=");
        if (key && value) {
          acc[key.trim()] = value.trim();
        }
        return acc;
      }, {});
    } catch (error) {
      if (error.code === "ENOENT") {
        console.log(".env file does not exist, creating a new one.");
        return {}; // Return an empty object if the file doesn't exist
      } else {
        throw error; // Rethrow other errors
      }
    }
  }

  // Function to save updated data back to the .env file
  async function saveEnvFile(filePath, data) {
    const envContent = Object.entries(data)
      .map(([key, value]) => `${key}=${value}`)
      .join("\n");
    await fs.writeFile(filePath, envContent, { encoding: "utf8" });
  }

  const existingEnvData = await loadEnvFile(envFilePath);

  await setupAndExport({
    chains: [
      { name: "Ethereum", rpcUrl: "http://localhost:8545" },
      { name: "Avalanche", rpcUrl: "http://localhost:8546" },
      { name: "Moonbeam", rpcUrl: "http://localhost:8547" },
      { name: "Fantom", rpcUrl: "http://localhost:8548" },
      { name: "Polygon", rpcUrl: "http://localhost:8549" },
    ],
    relayInterval: 5000,
    callback: async (chain, data) => {
      console.log(data);
      // Prefix per chain
      const prefix = data.name.toUpperCase();

      // Save addresses with prefix
      existingEnvData[`LOCAL_${prefix}_GATEWAY_ADDRESS`] = data.gatewayAddress;

      existingEnvData[`LOCAL_${prefix}_GAS_RECEIVER_ADDRESS`] =
        data.gasReceiverAddress;

      existingEnvData[`LOCAL_${prefix}_RPC_URL`] = data.rpc;

      chain.usdc = await chain.deployToken(
        "Axelar Wrapped USDC",
        "aUSDC",
        6,
        BigInt(1e18)
      );

      existingEnvData[`LOCAL_${prefix}_USDC_ADDRESS`] = chain.usdc.address;
    },
  });

  // Save the updated .env data back to the file
  try {
    await saveEnvFile(envFilePath, existingEnvData);
    console.log("Chain data saved or updated in .env");
  } catch (error) {
    console.error("Error writing .env file:", error);
  }
})();
