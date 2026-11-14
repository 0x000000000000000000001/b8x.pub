import assert from 'node:assert/strict';
import { readFile, mkdtemp, rm, access } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { createRequire } from 'node:module';

const root = new URL('../../', import.meta.url);
const require = createRequire(new URL('run/bak/js/package.json', root));
const JSZip = require('jszip');
let source = await readFile(new URL('src/Util/File/Unzip.js', root), 'utf8');
for (const modulePath of ['jszip/dist/jszip.js', 'xxhash-wasm/esm/xxhash-wasm.js']) {
  source = source.replace(
    `../../node_modules/${modulePath}`,
    new URL(`run/bak/js/node_modules/${modulePath}`, root).href,
  );
}
const unzip = await import(`data:text/javascript;base64,${Buffer.from(source).toString('base64')}`);
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
const zip = new JSZip();
zip.file('sheet.html', '<h1>sheet</h1>');
zip.file('other.html', '<h1>other</h1>');
zip.file('nested/value.txt', 'value');
const content = await zip.generateAsync({ type: 'arraybuffer' });
const extract = unzip._unzipGoogleSheetAndExtractHtml('sheet')(content);
assert.equal(typeof extract, 'function');
assert.equal(await run(extract), '<h1>sheet</h1>');
assert.equal(await run(extract), '<h1>sheet</h1>');
assert.equal(await run(unzip._unzipGoogleSheetAndExtractHtml('')(content)), '<h1>sheet</h1>');
assert.equal(await run(unzip._unzipGoogleSheetAndExtractHtml('other')(content)), '<h1>other</h1>');
await assert.rejects(run(unzip._unzipGoogleSheetAndExtractHtml('missing')(content)));
await assert.rejects(
  run(unzip._unzipGoogleSheetAndExtractHtml('sheet')(new Uint8Array([1, 2, 3]).buffer)),
);
const scratch = await mkdtemp(join(tmpdir(), 'b8x-unzip-'));
const output = join(scratch, 'output');
try {
  const extractDirectory = unzip._unzipToDirectory(output)(content);
  await assert.rejects(access(output));
  assert.equal(await run(extractDirectory), undefined);
  assert.equal(await readFile(join(output, 'nested/value.txt'), 'utf8'), 'value');
} finally {
  await rm(scratch, { recursive: true, force: true });
}
console.log('Unzip JavaScript FFI checks passed');
