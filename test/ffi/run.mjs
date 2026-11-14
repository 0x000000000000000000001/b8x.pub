// Run all local FFI checks: node /path/to/b8x/test/ffi/run.mjs
// Requires PHP and the existing JavaScript/PHP dependencies; no external services.
import { readdir } from "node:fs/promises";
import { spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";

const directory = new URL("./", import.meta.url);
const projectRoot = fileURLToPath(new URL("../../", directory));
const suites = (await readdir(directory, { withFileTypes: true }))
  .filter(
    (entry) =>
      entry.isFile() &&
      /\.(php|mjs)$/.test(entry.name) &&
      entry.name !== "run.mjs",
  )
  .map((entry) => entry.name)
  .sort();

if (suites.length === 0) {
  console.error("No FFI suites found.");
  process.exitCode = 1;
}

for (const suite of suites) {
  console.log(`\nRunning ${suite}`);
  const path = fileURLToPath(new URL(suite, directory));
  const isPhp = suite.endsWith(".php");
  const result = spawnSync(
    isPhp ? "php" : process.execPath,
    isPhp ? [path] : ["--experimental-vm-modules", path],
    { cwd: projectRoot, stdio: "inherit" },
  );
  if (result.error) {
    console.error(`Cannot run ${suite}: ${result.error.message}`);
  }
  if (result.status !== 0) {
    process.exitCode ||= result.status ?? 1;
  }
  if (result.signal) {
    console.error(`${suite} stopped by ${result.signal}.`);
    break;
  }
}
