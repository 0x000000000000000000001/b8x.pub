import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { createRequire } from 'node:module';
import { pathToFileURL } from 'node:url';

const root = new URL('../../', import.meta.url);
const require = createRequire(new URL('run/bak/js/package.json', root));
async function load(relativePath) {
  let source = await readFile(new URL(relativePath, root), 'utf8');
  for (const name of ['xxhash-wasm', 'paseto']) {
    source = source
      .replaceAll(`'${name}'`, `'${pathToFileURL(require.resolve(name)).href}'`)
      .replaceAll(`"${name}"`, `"${pathToFileURL(require.resolve(name)).href}"`);
  }
  return import(`data:text/javascript;base64,${Buffer.from(source).toString('base64')}`);
}
function run(operation) {
  return new Promise((resolve, reject) => {
    const cancel = operation(reject, resolve);
    let cancelled = false;
    cancel(null, reject, () => {
      cancelled = true;
    });
    assert.equal(cancelled, true);
  });
}

const hash = await load('src/Util/Crypto/Hash.js');
for (const [input, expected] of [
  ['', 'ef46db3751d8e999'],
  ['abc', '44bc2cf5ad770999'],
]) {
  const operation = hash._xxhash64(input);
  assert.equal(typeof operation, 'function');
  assert.equal(await run(operation), expected);
  assert.equal(await run(operation), expected);
}
const paseto = await load('src/Util/Crypto/Paseto/Paseto.js');
const key = '12'.repeat(32);
const operation = paseto.encryptV3LocalImpl(key)({ subject: 'ffi-test' })('2h');
const first = await run(operation);
const second = await run(operation);
assert.match(first, /^v3\.local\./);
assert.notEqual(first, second);
assert.equal((await run(paseto.decryptV3LocalImpl(key)(first))).subject, 'ffi-test');
await assert.rejects(run(paseto.decryptV3LocalImpl(key)('invalid')));
await assert.rejects(run(paseto.encryptV3LocalImpl('12')({})('2h')));
console.log('Crypto JavaScript FFI checks passed');
