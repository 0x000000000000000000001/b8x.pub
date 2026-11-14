import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';

const calls = [];
const connections = [];
let nextLock = true;
let failure;
class Client {
  constructor(config) {
    this.config = config;
    this.events = {};
    connections.push(this);
  }
  async connect() {
    if (failure) throw failure;
    return this;
  }
  async query(query, params) {
    calls.push([query, params]);
    if (failure) throw failure;
    return query.includes('pg_try_advisory_lock')
      ? { rows: [{ locked: nextLock }] }
      : { rows: [{ value: 42 }], rowCount: 3 };
  }
  async end() {
    this.closed = true;
  }
  release() {
    this.released = true;
  }
  on(event, callback) {
    this.events[event] = callback;
  }
}
globalThis.postgresDouble = { Pool: Client, Client };
async function loadFfi(path) {
  const source = (
    await readFile(new URL(`../../src/${path}`, import.meta.url), 'utf8')
  ).replace("import pk from 'pg';", 'const pk = globalThis.postgresDouble;');
  return import(
    `data:text/javascript;base64,${Buffer.from(source).toString('base64')}`
  );
}
function run(operation) {
  let cancel;
  const result = new Promise((resolve, reject) => {
    cancel = operation(reject, resolve);
  });
  return { result, cancel };
}

const pg = await loadFfi('Infra/Client/Postgres/Postgres.js');
const poolEffect =
  pg._createConnectionPoolHandle('localhost')(5432)('db')('user')('password')(
    2500,
  );
assert.equal(connections.length, 0);
const pool = poolEffect();
const operation = pg._query(JSON.stringify)(pool)('SELECT $1')([1]);
assert.deepEqual(calls, []);
assert.deepEqual(await run(operation).result, [{ value: 42 }]);
assert.deepEqual(calls, [['SELECT $1', [1]]]);
assert.equal(
  await run(pg._queryCount(JSON.stringify)(pool)('UPDATE rows')([])).result,
  3,
);
assert.equal(await run(pg._dedicate(pool)).result, pool);
await run(pg._release(pool)).result;
assert.equal(pool.released, true);
const error = new Error('database failure');
failure = error;
await assert.rejects(
  run(pg._query(JSON.stringify)(pool)('SELECT 1')([])).result,
  (candidate) => candidate === error,
);
failure = undefined;
const pending = run(pg._query(JSON.stringify)(pool)('SELECT 2')([]));
let cancelled = 0;
pending.cancel(
  new Error('cancel'),
  () => assert.fail('Cancellation failed'),
  () => {
    cancelled++;
  },
);
assert.equal(cancelled, 1);
assert.deepEqual(await pending.result, [{ value: 42 }]);
await run(pg._closeHandle(pool)).result;
assert.equal(pool.closed, true);
assert.equal(pg._escapeIdentifier('some"table'), '"some""table"');

const projector = await loadFfi('Infra/Projection/Projector.js');
const lock = (name) =>
  projector._tryAdvisoryLock('localhost')(5432)('db')('user')('password')(name);
const before = connections.length;
const acquire = lock('schema');
assert.equal(connections.length, before);
assert.equal(await run(acquire).result, true);
const lockConnection = connections.at(-1);
assert.equal(typeof lockConnection.events.error, 'function');
assert.equal(typeof lockConnection.events.end, 'function');
assert.equal(await run(acquire).result, false);
assert.equal(connections.length, before + 1);
nextLock = false;
assert.equal(await run(lock('busy')).result, false);
assert.equal(connections.at(-1).closed, true);
failure = error;
assert.equal(await run(lock('offline')).result, false);
assert.equal(connections.at(-1).closed, true);
console.log('PostgreSQL and projector JavaScript FFI checks passed');
