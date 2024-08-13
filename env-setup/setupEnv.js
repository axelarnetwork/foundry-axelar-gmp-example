import { readFileSync, writeFileSync, existsSync } from "fs";
import { join, dirname } from "path";
import { fileURLToPath } from "url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const rootDir = join(__dirname, "..");
const envPath = join(rootDir, ".env");
const envExamplePath = join(rootDir, ".env.example");

function initializeEnvFile() {
  console.log("Initializing .env file...");
  try {
    const contents = readFileSync(envExamplePath, "utf8");
    writeFileSync(envPath, contents);
    console.log(".env file created successfully in the root directory.");
  } catch (error) {
    console.error(`Error initializing .env file: ${error.message}`);
    process.exit(1);
  }
}

function main() {
  if (!existsSync(envPath)) {
    initializeEnvFile();
  } else {
    console.log(
      "A .env file already exists in the root directory. No changes made."
    );
  }
}

main();
