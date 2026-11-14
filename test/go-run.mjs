import assert from "node:assert/strict";
import { spawn, execFileSync } from "node:child_process";
import { createHash } from "node:crypto";
import { mkdtempSync, mkdirSync, readFileSync, writeFileSync, readdirSync, rmSync, existsSync, realpathSync, statSync, utimesSync } from "node:fs";
import { tmpdir } from "node:os";
import { join, delimiter } from "node:path";
import { fileURLToPath } from "node:url";
import { setTimeout as delay } from "node:timers/promises";
import { test } from "node:test";

const helper = process.env.B8X_GO_RUN_TEST_HELPER || fileURLToPath(new URL("../bin/_go-run", import.meta.url));
const sha256 = data => createHash("sha256").update(data).digest("hex");
const python = process.platform === "darwin" ? execFileSync("which", ["python3"], { encoding: "utf8" }).trim() : null;
const fakeGo = `#!${process.execPath}
const fs=require('node:fs'),cp=require('node:child_process'),crypto=require('node:crypto');
const log=(kind,extra={})=>fs.appendFileSync(process.env.EVENTS,JSON.stringify({kind,pid:process.pid,time:Date.now(),...extra})+'\\n');
if(process.argv[2]==='env'){console.log('linux\\narm64');process.exit(0)}
if(process.argv[2]!=='build')process.exit(90);
const args=process.argv.slice(3),output=args[args.indexOf('-o')+1];
const artifact=fs.readFileSync(args.at(-1),'utf8');
log('build-start',{args,seed:crypto.createHash('sha256').update(fs.readFileSync(output)).digest('hex'),env:Object.fromEntries(['GOMAXPROCS','GOMEMLIMIT','GOCACHE','GOMODCACHE','GOWORK'].map(x=>[x,process.env[x]]))});
if(process.env.SPAWN_BUILD_CHILD){
 cp.spawn(process.execPath,['-e',\"const fs=require('node:fs');process.on('SIGTERM',()=>{fs.writeFileSync(process.env.CHILD_STOPPED,'stopped');process.exit(0)});fs.writeFileSync(process.env.CHILD_READY,'ready');setInterval(()=>{},1000)\"],{stdio:'ignore'});
}
const build=()=>{
 if(process.env.BUILD_RELEASE&&!fs.existsSync(process.env.BUILD_RELEASE)){setTimeout(build,10);return}
 if(process.env.BUILD_FAIL){fs.writeFileSync(output,'incomplete');log('build-failed');process.exit(Number(process.env.BUILD_FAIL))}
 const body=\"#!\"+process.execPath+\"\\nconst artifact=\"+JSON.stringify(artifact)+\";\\n\"+
 \"const fs=require('node:fs');const emit=(kind)=>fs.appendFileSync(process.env.EVENTS,JSON.stringify({kind,artifact,pid:process.pid,time:Date.now(),args:process.argv.slice(2),cwd:process.cwd(),umask:process.umask(),env:Object.fromEntries(['GOMAXPROCS','GOMEMLIMIT','GOCACHE','GOMODCACHE','GOWORK'].map(x=>[x,process.env[x]]))})+'\\\\n');emit('app-start');setTimeout(()=>{emit('app-end');process.exit(Number(process.env.APP_EXIT||0))},Number(process.env.APP_PAUSE_MS||0));\\n\";
 fs.writeFileSync(output,body);log('build-end');
};setTimeout(build,Number(process.env.BUILD_PAUSE_MS||0));
`;
function fixture(t, native = false) {
  const root = mkdtempSync(join(process.env.B8X_GO_RUN_TEST_EVIDENCE ?? tmpdir(), "b8x-go-run-"));
  t.after(() => {
    if (process.env.B8X_GO_RUN_TEST_EVIDENCE) console.log("Go runner evidence: " + root);
    else rmSync(root, { recursive: true, force: true });
  });
  const output = join(root, "run/bak/go/output"), tools = join(root, "tools");
  mkdirSync(output, { recursive: true }); mkdirSync(tools);
  const entry = join(output, "main with spaces.go"); writeFileSync(entry, "package main");
  if (!native) writeFileSync(join(tools, "go"), fakeGo, { mode: 0o755 });
  if (python) {
    // macOS has no util-linux commands; these shims use the same kernel primitives.
    writeFileSync(join(tools, "flock"), `#!${python}\nimport fcntl,sys\ntry:\n fcntl.flock(int(sys.argv[-1]),fcntl.LOCK_EX | (fcntl.LOCK_NB if '-n' in sys.argv else 0))\nexcept BlockingIOError:\n sys.exit(75)\n`, { mode: 0o755 });
    writeFileSync(join(tools, "setsid"), `#!${python}\nimport os,sys\nos.setsid()\nos.execvp(sys.argv[1],sys.argv[1:])\n`, { mode: 0o755 });
  }
  const log = join(root, "events.jsonl"); writeFileSync(log, "");
  const env = { ...process.env, ROOT_DIR: root, EVENTS: log, PATH: tools + delimiter + process.env.PATH,
    CHILD_READY: join(root, "child-ready"), CHILD_STOPPED: join(root, "child-stopped") };
  for (const key of ["GOMAXPROCS", "GOMEMLIMIT", "GOCACHE", "GOMODCACHE", "GOWORK", "GOFLAGS", "GOEXPERIMENT", "B8X_GO_BUILD_PROCS", "B8X_GO_BUILD_MEMORY", "B8X_GO_BUILD_PARALLELISM"]) delete env[key];
  const events = () => readFileSync(log, "utf8").trim().split("\n").filter(Boolean).map(JSON.parse);
  let sequence = 0;
  const start = (extra = {}, args = [], selectedEntry = entry) => {
    const label = sequence++;
    const child = spawn(helper, [output, selectedEntry, ...args], { env: { ...env, ...extra }, stdio: ["ignore", "pipe", "pipe"] });
    let stderr = "", stdout = "";
    child.stderr.on("data", x => { stderr += x; }); child.stdout.on("data", x => { stdout += x; });
    const done = new Promise((resolve, reject) => {
      child.on("error", reject); child.on("close", (code, signal) => {
        if (process.env.B8X_GO_RUN_TEST_EVIDENCE) {
          writeFileSync(join(root, label + ".stdout"), stdout);
          writeFileSync(join(root, label + ".stderr"), stderr);
          writeFileSync(join(root, label + ".json"), JSON.stringify({ selectedEntry, args, extra, code, signal }));
        }
        resolve({ code, signal, stderr, stdout });
      });
    });
    t.after(() => { if (child.exitCode === null && child.signalCode === null) child.kill("SIGTERM"); });
    return { child, done, get stderr() { return stderr; } };
  };
  const cache = join(root, "var/api/cache/go");
  return { root, output, entry, env, events, start, cache, bins: () => readdirSync(join(cache, "bin")),
    latest: () => readdirSync(join(cache, "latest")).map(name => join(cache, "latest", name)) };
}
async function until(predicate) {
  for (let i = 0; i < 300; i++) { if (predicate()) return; await delay(10); }
  throw new Error("timed out waiting for fixture event");
}

test("build limits stay separate from runtime, arguments and exit status", { timeout: 10000 }, async t => {
  const f = fixture(t);
  const result = await f.start({ GOMAXPROCS: "7", GOMEMLIMIT: "2GiB", GOWORK: "caller-work", APP_EXIT: "23" }, ["Test", "two words", "--", ""]).done;
  assert.equal(result.code, 23, result.stderr);
  const build = f.events().find(x => x.kind === "build-start"), app = f.events().find(x => x.kind === "app-start");
  assert.equal(build.env.GOMAXPROCS, "4"); assert.equal(build.env.GOMEMLIMIT, "12GiB"); assert.equal(build.env.GOWORK, "off");
  assert.equal(build.env.GOCACHE, join(f.root, "var/api/cache/go/build"));
  assert.equal(build.env.GOMODCACHE, join(f.root, "var/api/cache/go/modules"));
  assert.equal(app.env.GOMAXPROCS, "7"); assert.equal(app.env.GOMEMLIMIT, "2GiB"); assert.equal(app.env.GOWORK, "caller-work");
  assert.equal(app.env.GOCACHE, undefined); assert.equal(app.env.GOMODCACHE, undefined);
  assert.equal(app.cwd, realpathSync(f.output)); assert.equal(app.umask, process.umask()); assert.deepEqual(app.args, ["Test", "two words", "--", ""]);
  assert.equal(f.bins().length, 1);
  assert.doesNotMatch(result.stderr, /Waiting for/);
  assert.match(result.stderr, /Go build lock acquired in \d+\.\d{3} s/);
  assert.match(result.stderr, /GOMAXPROCS=4, packages=-p 8, GOMEMLIMIT=12GiB/);
  assert.match(result.stderr, /Go validation\/build finished in \d+\.\d{3} s \(status 0\)/);
  assert.match(result.stderr, /Go preparation finished in \d+\.\d{3} s \(lock, cache and build\)/);
});

test("unchanged runs validate a private copy and keep the publication immutable", { timeout: 10000 }, async t => {
  const f = fixture(t); assert.equal((await f.start().done).code, 0);
  const binary = join(f.cache, "bin", f.bins()[0]), before = readFileSync(binary), stat = statSync(binary);
  const result = await f.start({ B8X_GO_BUILD_PROCS: "3", B8X_GO_BUILD_PARALLELISM: "2", B8X_GO_BUILD_MEMORY: "4GiB" }).done;
  assert.equal(result.code, 0, result.stderr);
  assert.match(result.stderr, /GOMAXPROCS=3, packages=-p 2, GOMEMLIMIT=4GiB/);
  const builds = f.events().filter(x => x.kind === "build-start");
  assert.equal(builds[0].seed, sha256("")); assert.equal(builds[1].seed, sha256(before));
  assert.notEqual(builds[1].args[builds[1].args.indexOf("-o") + 1], binary);
  assert.equal(builds[1].args[builds[1].args.indexOf("-p") + 1], "2");
  assert.equal(builds[1].env.GOMAXPROCS, "3"); assert.equal(builds[1].env.GOMEMLIMIT, "4GiB");
  assert.deepEqual(readFileSync(binary), before); assert.equal(statSync(binary).ino, stat.ino);
  assert.equal(statSync(binary).mtimeMs, stat.mtimeMs);
  assert.equal(f.bins().length, 1); assert.equal(f.latest().length, 1);
  assert.equal(readFileSync(f.latest()[0], "utf8"), sha256(before) + "\n");
});

test("failed builds never run the old binary and leave its publication intact", { timeout: 10000 }, async t => {
  const f = fixture(t); assert.equal((await f.start().done).code, 0);
  const binary = join(f.root, "var/api/cache/go/bin", f.bins()[0]), before = readFileSync(binary);
  const latest = readFileSync(f.latest()[0]);
  const result = await f.start({ BUILD_FAIL: "41" }).done;
  assert.equal(result.code, 41, result.stderr); assert.deepEqual(readFileSync(binary), before);
  assert.equal(f.bins().length, 1); assert.equal(f.events().filter(x => x.kind === "app-start").length, 1);
  assert.equal(f.events().filter(x => x.kind === "build-start").length, 2);
  assert.deepEqual(readFileSync(f.latest()[0]), latest); assert.equal(f.latest().length, 1);
  assert.match(result.stderr, /Go validation\/build finished in .* \(status 41\)/);
});

test("builds serialize but applications do not retain the build lock", { timeout: 10000 }, async t => {
  const f = fixture(t);
  const first = f.start({ BUILD_PAUSE_MS: "150", APP_PAUSE_MS: "700" });
  await until(() => f.events().some(x => x.kind === "build-start"));
  const second = f.start({ BUILD_PAUSE_MS: "150" });
  assert.equal((await first.done).code, 0); assert.equal((await second.done).code, 0);
  const events = f.events(), starts = events.filter(x => x.kind === "build-start"), ends = events.filter(x => x.kind === "build-end");
  assert.ok(starts[1].time >= ends[0].time, "builds overlapped");
  assert.ok(starts[1].time < events.find(x => x.kind === "app-end" && x.pid === first.child.pid).time, "application retained the build lock");
});

test("each invocation executes its own artifact after releasing the build lock", { timeout: 10000 }, async t => {
  const f = fixture(t), pause = join(f.root, "pause-before-exec.sh");
  const ready = join(f.root, "exec-ready"), release = join(f.root, "exec-release");
  // Intercept the last diagnostic to reproduce blocked stderr after unlocking.
  // This is a shell test fixture; the helper needs no testing hook.
  writeFileSync(pause, `printf() {
  if [[ "\${1:-}" == '[b8x] Running Go application.'* ]]; then
    : > "$PAUSE_READY"
    while [[ ! -f "$PAUSE_RELEASE" ]]; do sleep 0.01; done
  fi
  builtin printf "$@"
}
`);
  writeFileSync(f.entry, "package main // version A");
  const first = f.start({ BASH_ENV: pause, PAUSE_READY: ready, PAUSE_RELEASE: release });
  await until(() => existsSync(ready));
  writeFileSync(f.entry, "package main // version B");
  const second = f.start();
  try {
    assert.equal((await second.done).code, 0);
  } finally {
    writeFileSync(release, "release");
  }
  assert.equal((await first.done).code, 0);
  const apps = f.events().filter(x => x.kind === "app-start");
  assert.equal(apps.find(x => x.pid === first.child.pid).artifact, "package main // version A");
  assert.equal(apps.find(x => x.pid === second.child.pid).artifact, "package main // version B");
  assert.equal(f.bins().length, 2, "both immutable artifacts must remain available");
  assert.equal((await f.start().done).code, 0);
  assert.equal(f.bins().length, 2, "unchanged binary contents reuse the existing artifact");
});

test("cancelling a build stops its process group and releases the lock", { timeout: 10000 }, async t => {
  const f = fixture(t), first = f.start({ BUILD_PAUSE_MS: "10000", SPAWN_BUILD_CHILD: "1" });
  await until(() => existsSync(f.env.CHILD_READY)); first.child.kill("SIGTERM");
  assert.equal((await first.done).code, 143); await until(() => existsSync(f.env.CHILD_STOPPED));
  assert.equal(f.events().filter(x => x.kind === "app-start").length, 0);
  assert.equal(f.bins().length, 0); assert.equal((await f.start().done).code, 0);
});

test("cancelling a lock waiter never kills the active build", { timeout: 10000 }, async t => {
  const f = fixture(t), release = join(f.root, "release-build"), first = f.start({ BUILD_RELEASE: release });
  await until(() => f.events().some(x => x.kind === "build-start"));
  const second = f.start();
  try {
    await until(() => second.stderr.includes("Waiting for the Go build lock"));
    second.child.kill("SIGTERM");
    assert.equal((await second.done).code, 143); assert.equal(first.child.exitCode, null);
  } finally {
    writeFileSync(release, "release");
  }
  assert.equal((await first.done).code, 0);
  assert.equal(f.events().filter(x => x.kind === "build-start").length, 1);
});

test("after exec the application receives signals directly", { timeout: 10000 }, async t => {
  const f = fixture(t), running = f.start({ APP_PAUSE_MS: "10000" });
  await until(() => f.events().some(x => x.kind === "app-start")); running.child.kill("SIGTERM");
  assert.equal((await running.done).signal, "SIGTERM");
});

test("cancelling a seeded build preserves the previous publication and hint", { timeout: 10000 }, async t => {
  const f = fixture(t); assert.equal((await f.start().done).code, 0);
  const binary = join(f.cache, "bin", f.bins()[0]), before = readFileSync(binary), latest = readFileSync(f.latest()[0]);
  const running = f.start({ BUILD_PAUSE_MS: "10000", SPAWN_BUILD_CHILD: "1" });
  await until(() => existsSync(f.env.CHILD_READY)); running.child.kill("SIGTERM");
  assert.equal((await running.done).code, 143); await until(() => existsSync(f.env.CHILD_STOPPED));
  assert.deepEqual(readFileSync(binary), before); assert.deepEqual(readFileSync(f.latest()[0]), latest);
  assert.equal(f.bins().length, 1); assert.equal(f.latest().length, 1);
  assert.equal(f.events().filter(x => x.kind === "app-start").length, 1);
  assert.equal((await f.start().done).code, 0);
});

// Opt in on a machine with Go; the API container exercises util-linux and the
// production toolchain, while macOS uses only flock/setsid compatibility shims.
test("real Go skips warm links and invalidates sources, dependencies, modules and flags", {
  skip: process.env.B8X_GO_RUN_NATIVE_TEST !== "1", timeout: 180000,
}, async t => {
  const f = fixture(t, true);
  const dep = join(f.output, "dep"), alternate = join(f.output, "alternate");
  for (const dir of [dep, alternate]) {
    mkdirSync(dir); writeFileSync(join(dir, "go.mod"), "module probe/dependency\n\ngo 1.22\n");
  }
  writeFileSync(join(dep, "value.go"), 'package dependency\nconst Message = "one"\n');
  writeFileSync(join(alternate, "value.go"), 'package dependency\nconst Message = "alternate"\n');
  const mod = 'module probe/main\n\ngo 1.22\nrequire probe/dependency v0.0.0\nreplace probe/dependency => ./dep\n';
  writeFileSync(join(f.output, "go.mod"), mod);
  const main = 'package main\nimport("fmt";"probe/dependency")\nvar variant = "default"\nfunc main(){fmt.Println(dependency.Message, variant)}\n';
  writeFileSync(f.entry, main);
  let flags = "-x";
  const run = async (expected, linked) => {
    const result = await f.start({ GOFLAGS: flags, CGO_ENABLED: "0" }).done;
    assert.equal(result.code, 0, result.stderr); assert.equal(result.stdout, expected + "\n");
    const lines = result.stderr.split("\n");
    const links = lines.filter(x => /\/pkg\/tool\/.*\/link /.test(x));
    const compiles = lines.filter(x => /\/pkg\/tool\/.*\/compile /.test(x));
    assert.equal(links.length, linked ? 1 : 0, result.stderr);
    if (!linked) assert.equal(compiles.length, 0, result.stderr);
    return result;
  };
  await run("one default", true);
  const originalPath = join(f.cache, "bin", f.bins()[0]), original = readFileSync(originalPath);
  await run("one default", false);
  const modified = main.replace("fmt.Println(", 'fmt.Println("entry", ');
  writeFileSync(f.entry, modified); await run("entry one default", true);
  assert.deepEqual(readFileSync(originalPath), original);
  const value = join(dep, "value.go"), stat = statSync(value);
  writeFileSync(value, 'package dependency\nconst Message = "two"\n'); utimesSync(value, stat.atime, stat.mtime);
  await run("entry two default", true);
  flags = "-x -ldflags=-X=main.variant=flagged";
  await run("entry two flagged", true);
  writeFileSync(join(f.output, "go.mod"), mod.replace("./dep", "./alternate"));
  await run("entry alternate flagged", true);
  const pointer = f.latest()[0], hash = readFileSync(pointer, "utf8"), count = f.bins().length;
  writeFileSync(f.entry, "invalid Go source\n");
  const failed = await f.start({ GOFLAGS: flags, CGO_ENABLED: "0" }).done;
  assert.notEqual(failed.code, 0); assert.equal(failed.stdout, ""); assert.doesNotMatch(failed.stderr, /Running Go application/);
  assert.equal(readFileSync(pointer, "utf8"), hash); assert.equal(f.bins().length, count);
  writeFileSync(f.entry, modified); await run("entry alternate flagged", false);
  rmSync(pointer); await run("entry alternate flagged", true);
  writeFileSync(pointer, "../../not-a-hash\n"); await run("entry alternate flagged", true);
  const binary = join(f.cache, "bin", f.bins().find(name => name.endsWith(hash.trim()))), valid = readFileSync(binary);
  // Appending bytes leaves the Go build ID intact: the runner must detect damage.
  writeFileSync(binary, Buffer.concat([valid, Buffer.from("damaged")]));
  const repaired = await run("entry alternate flagged", true);
  assert.match(repaired.stderr, /Previous Go binary is damaged/); assert.deepEqual(readFileSync(binary), valid);
  rmSync(binary); await run("entry alternate flagged", true);
  assert.deepEqual(readFileSync(binary), valid); await run("entry alternate flagged", false);
  assert.equal(f.latest().length, 1); assert.equal(f.bins().length, count);

  // The same runner key must survive a monolithic -> multipackage migration.
  // Go follows the new imports; the hint never pretends to describe the graph.
  const leaf = join(f.output, "purescript/p_leaf"), spare = join(f.output, "purescript/p_spare");
  for (const directory of [leaf, spare]) mkdirSync(directory, { recursive: true });
  const leafFile = join(leaf, "value.go");
  writeFileSync(leafFile, 'package p_leaf\nimport "probe/dependency"\nfunc Message() string {return dependency.Message}\n');
  writeFileSync(join(spare, "value.go"), 'package p_spare\nfunc Unchanged() string {return "spare"}\n');
  const split = modified.replace('"probe/dependency"', 'dependency "probe/main/purescript/p_leaf"; _ "probe/main/purescript/p_spare"')
    .replace("dependency.Message,", "dependency.Message(),");
  writeFileSync(f.entry, split);
  await run("entry alternate flagged", true);
  const lock = statSync(join(f.cache, "build.lock"));
  const hint = f.latest()[0];
  await run("entry alternate flagged", false);
  writeFileSync(leafFile, 'package p_leaf\nimport "probe/dependency"\nfunc Message() string {return dependency.Message+":leaf"}\n');
  const changed = await run("entry alternate:leaf flagged", true);
  const actions = changed.stderr.split("\n").filter(line => /\/pkg\/tool\/.*\/compile /.test(line));
  assert(actions.some(line => line.includes(" -p probe/main/purescript/p_leaf ")));
  assert(!actions.some(line => line.includes(" -p probe/main/purescript/p_spare ")));
  assert.equal(f.latest()[0], hint);
  assert.equal(statSync(join(f.cache, "build.lock")).ino, lock.ino);
  await run("entry alternate:leaf flagged", false);

  const secondEntry = join(f.output, "second-main.go");
  writeFileSync(secondEntry, 'package main\nimport("fmt";"probe/main/purescript/p_leaf")\nfunc main(){fmt.Println("second",p_leaf.Message())}\n');
  const second = await f.start({ GOFLAGS: "-x", CGO_ENABLED: "0" }, [], secondEntry).done;
  assert.equal(second.code, 0, second.stderr);
  assert.equal(second.stdout, "second alternate:leaf\n");
  assert.equal(f.latest().length, 2, "distinct entry keys");
  const replay = await f.start({ GOFLAGS: "-x", CGO_ENABLED: "0" }, [], secondEntry).done;
  assert.equal(replay.code, 0, replay.stderr);
  assert.doesNotMatch(replay.stderr, /\/pkg\/tool\/.*\/(?:compile|link) /);
  await run("entry alternate:leaf flagged", false);
  writeFileSync(f.entry, modified);
  await run("entry alternate flagged", true);
  await run("entry alternate flagged", false);
});
