import { setupAndExport } from "@axelar-network/axelar-local-dev";
import { promises as fs } from "fs";
import { ethers } from "ethers";

(async () => {
  const envFilePath = ".env"; // Path to your .env file

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

  async function saveEnvFile(filePath, data) {
    const envContent = Object.entries(data)
      .map(([key, value]) => `${key}=${value}`)
      .join("\n");
    await fs.writeFile(filePath, envContent, { encoding: "utf8" });
  }

  const existingEnvData = await loadEnvFile(envFilePath);

  const toFund = [
    "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266",
    "0x70997970C51812dc3A010C7d01b50e0d17dc79C8",
    "0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC",
    "0x90F79bf6EB2c4f870365E785982E1f101E93b906",
    "0x15d34AAf54267DB7D7c367839AAf71A00a2C6A65",
    "0x9965507D1a55bcC2695C58ba16FB37d819B0A4dc",
    "0x976EA74026E726554dB657fA54763abd0C3a0aa9",
    "0x14dC79964da2C08b23698B3D3cc7Ca32193d9955",
    "0x23618e81E3f5cdF7f54C3d65f7FBc0aBf5B21E8f",
    "0xa0Ee7A142d267C1f36714E4a8F75612F20a79720",
  ];

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

      // Fund each address with 1 aUSDC
      for (const address of toFund) {
        await chain.giveToken(
          address,
          "aUSDC",
          ethers.utils.parseEther("1")
        );
      }
    },
  });

  try {
    await saveEnvFile(envFilePath, existingEnvData);
    console.log("Chain data saved or updated in .env");
  } catch (error) {
    console.error("Error writing .env file:", error);
  }
})();


