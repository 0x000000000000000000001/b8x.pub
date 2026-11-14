# Native FFI checks

Run the local PHP and JavaScript suites from any working directory:

```sh
node /path/to/b8x/test/ffi/run.mjs
```

The suites use the dependencies installed in `run/bak/php/vendor` and
`run/bak/js/node_modules`. Database, mail, queue and storage clients use doubles;
no external service or application configuration is needed. Crypto, ZIP and
event-loop checks exercise the installed libraries directly.

`Native.purs` also checks the compiled boundary: `Aff` replay, callback values and
errors, encryption round trips, and timer effects. After building the selected
target, run it from the project root:

```sh
# PHP output, built with the PHP target's package set
php -d opcache.enable_cli=0 output/Test.Ffi.Native/main.mod.php

# JavaScript output, built with the JavaScript target's package set
node --input-type=module -e 'import { main } from "./output/Test.Ffi.Native/index.js"; main();'
```

Successful execution prints `NATIVE FFI INTEGRATION PASSED`. Use each target's
own package set: JavaScript files emitted during a PHP build can accompany
PHP-specific foreign signatures and are not a JavaScript runtime build.

The application FFI uses `EffectFnAff` for asynchronous work and `EffectFnN`
for native effectful calls. Its public wrappers retain `Aff` and `Effect`.
Cancellation acknowledges the request without aborting an already started SDK
operation. PostgreSQL receives its JSON encoder from PureScript, leaving runtime
value normalization in the JSON library.
