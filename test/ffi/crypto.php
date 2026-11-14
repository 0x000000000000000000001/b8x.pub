<?php

require dirname(__DIR__, 2) . '/run/bak/php/vendor/autoload.php';

function cryptoCheck(bool $condition, string $message): void
{
    if (!$condition) {
        throw new RuntimeException($message);
    }
}

function cryptoRun(callable $operation): mixed
{
    $settled = false;
    $result = null;
    $failure = null;
    $cancel = $operation(
        function ($error) use (&$settled, &$failure) {
            cryptoCheck(!$settled, 'Operation settled twice');
            $settled = true;
            $failure = $error;
        },
        function ($value) use (&$settled, &$result) {
            cryptoCheck(!$settled, 'Operation settled twice');
            $settled = true;
            $result = $value;
        },
    );
    cryptoCheck($settled, 'Synchronous operation did not settle');
    $cancelled = false;
    $cancel(null, fn($error) => throw $error, function () use (&$cancelled) {
        $cancelled = true;
    });
    cryptoCheck($cancelled, 'Canceler did not complete');
    if ($failure !== null) {
        throw $failure;
    }
    return $result;
}

$exports = [];
$hash = require dirname(__DIR__, 2) . '/src/Util/Crypto/Hash.php';
foreach (['', 'abc', 'é漢字', str_repeat('x', 128)] as $input) {
    $operation = $hash['_xxhash64']($input);
    cryptoCheck(is_callable($operation), 'Hash started before registration');
    cryptoCheck(cryptoRun($operation) === hash('xxh64', $input), 'Wrong XXH64 digest');
    cryptoCheck(cryptoRun($operation) === hash('xxh64', $input), 'Hash could not replay');
    cryptoCheck($hash['_md5']($input) === md5($input), 'Wrong MD5 digest');
    cryptoCheck($hash['_sha256']($input) === hash('sha256', $input), 'Wrong SHA256 digest');
}
cryptoCheck(
    $hash['hmacSha256']('key', 'message') === hash_hmac('sha256', 'message', 'key'),
    'Wrong HMAC',
);
$callbackFailure = new RuntimeException('callback failed');
$errors = 0;
try {
    $hash['_xxhash64']('abc')(function () use (&$errors) {
        $errors++;
    }, fn() => throw $callbackFailure);
    throw new RuntimeException('Success callback exception was swallowed');
} catch (RuntimeException $error) {
    cryptoCheck(
        $error === $callbackFailure && $errors === 0,
        'Success callback was reported as operation failure',
    );
}

$exports = [];
$paseto = require dirname(__DIR__, 2) . '/src/Util/Crypto/Paseto/Paseto.php';
$key = str_repeat('12', 32);
$encrypt = $paseto['encryptV3LocalImpl']($key, ['subject' => 'ffi-test'], '2h');
$firstToken = cryptoRun($encrypt);
$secondToken = cryptoRun($encrypt);
cryptoCheck(str_starts_with($firstToken, 'v3.local.'), 'Invalid token prefix');
cryptoCheck($firstToken !== $secondToken, 'Encryption did not replay');
$claims = cryptoRun($paseto['decryptV3LocalImpl']($key, $firstToken));
cryptoCheck($claims['subject'] === 'ffi-test', 'Payload roundtrip failed');
foreach (
    [$paseto['decryptV3LocalImpl']($key, 'invalid'), $paseto['encryptV3LocalImpl']('12', [], '2h')]
    as $operation
) {
    $failed = false;
    try {
        cryptoRun($operation);
    } catch (Throwable) {
        $failed = true;
    }
    cryptoCheck($failed, 'Invalid PASETO input succeeded');
}
echo "Crypto PHP FFI checks passed\n";
