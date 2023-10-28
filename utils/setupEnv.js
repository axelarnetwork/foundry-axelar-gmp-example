import fs from "fs";
import path from "path";
import chalk from "chalk";

const log = (message) => console.log(message);
const dirname = path.dirname(new URL(import.meta.url).pathname);
const envExamplePath = path.join(dirname, "..", ".env.example");
const envPath = path.join(dirname, "..", ".env");

if (!fs.existsSync(".env")) {
  log(chalk.yellow("⤵ Reading .env.example."));
  fs.writeFileSync(envPath, fs.readFileSync(envExamplePath));
  log(chalk.yellow(`⤵ Creating .env file in ${path.dirname(dirname)}.`));
  log(chalk.green("📨 Created .env file successfully!"));
} else {
  log(
    chalk.blueBright(
      `A .env file already exists in ${path.dirname(
        dirname
      )}, not modifying it.`
    )
  );
}
