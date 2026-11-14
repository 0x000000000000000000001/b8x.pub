<?php

$exports['_md5'] = static fn($input) => hash('md5', $input);
$exports['_sha256'] = static fn($input) => hash('sha256', $input);

$exports['_xxhash64'] = static function ($input) {
    return static function ($onError, $onSuccess) use ($input) {
        $cancel = static fn($reason, $onCancelerError, $onCancelerSuccess) => $onCancelerSuccess(
            null,
        );
        try {
            if (!\in_array('xxh64', \hash_algos(), true)) {
                throw new \RuntimeException('xxh64 is not available in this PHP build');
            }
            $result = hash('xxh64', $input);
        } catch (\Throwable $failure) {
            $onError($failure);
            return $cancel;
        }
        $onSuccess($result);
        return $cancel;
    };
};

$exports['hmacSha256'] = static fn($secret, $message) => hash_hmac('sha256', $message, $secret);

return $exports;
