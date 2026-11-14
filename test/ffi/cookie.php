<?php

function cookieCheck(bool $condition, string $message): void
{
    if (!$condition) {
        throw new RuntimeException($message);
    }
}

$exports = require dirname(__DIR__, 2) . '/src/Util/Cookie/Cookie.php';

// Expected values produced by the JavaScript cookie package used by Cookie.js.
cookieCheck(
    $exports['serializeImpl']('session', 'a b+c%', 3600, true, '/', true, 'lax', 'example.com') ===
        'session=a%20b%2Bc%25; Max-Age=3600; Domain=example.com; Path=/; HttpOnly; Secure; SameSite=Lax',
    'Serialize output must match the JavaScript cookie package',
);

cookieCheck(
    $exports['serializeImpl']('k', 'v', 0, false, '', false, '', '') === 'k=v; Max-Age=0',
    'Empty optional attributes must be omitted',
);

cookieCheck(
    $exports['parse']('a=1; b=x%20y; c=%2B; d="quoted"; junk') ===
        ['a' => '1', 'b' => 'x y', 'c' => '+', 'd' => '"quoted"'],
    'Parse output must match the JavaScript cookie package',
);

echo "Cookie PHP FFI checks passed\n";
