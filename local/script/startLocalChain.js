import { setupAndExport } from "@axelar-network/axelar-local-dev";
import { promises as fs } from "fs";
import { ethers } from "ethers";

(async () => {
  const envFilePath = ".env"; // Path to your .env file

  // Function to load the .env file and parse its contents into an object
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
        return {};
      } else {
        throw error;
      }
    }
  }

  // Function to write the updated object back to the .env file
  async function saveEnvFile(filePath, data) {
    const envContent = Object.entries(data)
      .map(([key, value]) => `${key}=${value}`)
      .join("\n");
    await fs.writeFile(filePath, envContent, { encoding: "utf8" });
  }

  // Load existing .env data or initialize a new object if the file doesn't exist
  const existingEnvData = await loadEnvFile(envFilePath);

  const toFund = ["0x70997970C51812dc3A010C7d01b50e0d17dc79C8"];

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
      const prefix = data.name.toUpperCase();

      // Update or add new data for each chain
      existingEnvData[`LOCAL_${prefix}_GATEWAY_ADDRESS`] = data.gatewayAddress;
      existingEnvData[`LOCAL_${prefix}_GAS_RECEIVER_ADDRESS`] =
        data.gasReceiverAddress;
      existingEnvData[`LOCAL_${prefix}_RPC_URL`] = data.rpc;

      chain.usdc = await chain.deployToken(
        "Axelar Wrapped USDC",
        "aUSDC",
        6,
        ethers.utils.parseEther("1000")
      );

      existingEnvData[`LOCAL_${prefix}_USDC_ADDRESS`] = chain.usdc.address;

      // Fund each address with 10 aUSDC
      for (const address of toFund) {
        await chain.giveToken(
          address,
          "aUSDC",
          ethers.utils.parseUnits("200", 6)
        );
      }
    },
  });

  try {
    // Save the updated or new .env data
    await saveEnvFile(envFilePath, existingEnvData);
    console.log("Chain data saved or updated in .env");
  } catch (error) {
    console.error("Error writing .env file:", error);
  }
})();
