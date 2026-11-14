import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { EventEmitter } from 'node:events';

const root = new URL('../../', import.meta.url);
async function load(relativePath) {
  const source = await readFile(new URL(relativePath, root), 'utf8');
  return import(`data:text/javascript;base64,${Buffer.from(source).toString('base64')}`);
}
const effect = await load('../phpurs/phpurs-effect/src/Effect/Uncurried.js');
const timer = await load('src/Util/Timer.js');
const signal = await load('src/Util/Signal.js');
const auth = await load('src/Inter/Api/Membership/Auth.js');

const originalSetInterval = global.setInterval;
const originalClearInterval = global.clearInterval;
let scheduled = null;
let cleared = null;
const id = {
  ref() {
    this.referenced = true;
  },
  unref() {
    this.referenced = false;
  },
};
try {
  global.setInterval = (callback, milliseconds) => {
    scheduled = { callback, milliseconds };
    return id;
  };
  global.clearInterval = (interval) => {
    cleared = interval;
  };
  let calls = 0;
  const start = effect.runEffectFn2(timer.setIntervalImpl)(25)(() => {
    calls++;
  });
  assert.equal(scheduled, null);
  assert.equal(start(), id);
  assert.equal(scheduled.milliseconds, 25);
  assert.equal(id.referenced, true);
  assert.equal(calls, 0);
  scheduled.callback();
  assert.equal(calls, 1);
  const clear = effect.runEffectFn1(timer.clearIntervalImpl)(id);
  assert.equal(cleared, null);
  clear();
  assert.equal(cleared, id);
  assert.equal(id.referenced, false);
} finally {
  global.setInterval = originalSetInterval;
  global.clearInterval = originalClearInterval;
}
const originalOn = process.on;
const signals = new EventEmitter();
try {
  process.on = signals.on.bind(signals);
  let calls = 0;
  const register = effect.runEffectFn2(signal.onSignalImpl)('SIGINT')(() => {
    calls++;
  });
  assert.equal(signals.listenerCount('SIGINT'), 0);
  register();
  assert.equal(signals.listenerCount('SIGINT'), 1);
  assert.equal(calls, 0);
  signals.emit('SIGINT');
  assert.equal(calls, 1);
} finally {
  process.on = originalOn;
}
const headers = [];
const response = { appendHeader: (name, value) => headers.push([name, value]) };
const append = effect.runEffectFn3(auth.appendHeaderImpl)('Set-Cookie')('one=1')(response);
assert.deepEqual(headers, []);
append();
auth.appendHeaderImpl('Set-Cookie', 'two=2', response);
assert.deepEqual(headers, [
  ['Set-Cookie', 'one=1'],
  ['Set-Cookie', 'two=2'],
]);
const timestamp = auth.nowIso();
assert.match(timestamp, /^\d{4}-\d\d-\d\dT\d\d:\d\d:\d\d\.\d{3}Z$/);
assert.ok(Math.abs(Date.parse(timestamp) - Date.now()) < 1000);
console.log('Effect JavaScript FFI checks passed');
