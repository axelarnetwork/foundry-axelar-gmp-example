import { readFileSync, writeFileSync, existsSync } from "fs";
import { join, dirname } from "path";
import { fileURLToPath } from "url";

// Get the directory name of the current module
const __dirname = dirname(fileURLToPath(import.meta.url));

const rootDir = join(__dirname, "..", "..");
const envPath = join(rootDir, ".env");
const envExamplePath = join(rootDir, ".env.example");

function initializeEnvFile() {
  console.log("Copying .env.example to .env");

  let contents;
  try {
    contents = readFileSync(envExamplePath, "utf8");
  } catch (error) {
    console.error(`Error reading .env.example: ${error.message}`);
    return;
  }

  // Copy .env.example contents to .env
  console.log("Creating .env file in the root directory.");
  writeFileSync(envPath, contents);
}

// Main script execution
if (!existsSync(envPath)) {
  initializeEnvFile();
} else {
  console.log(
    "A .env file already exists in the root directory, not modifying it."
  );
}
