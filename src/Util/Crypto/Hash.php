<?php

$exports['_md5'] = function($str) { return hash('md5', $str); };
$exports['_sha256'] = function($str) { return hash('sha256', $str); };

$exports['_xxhash64'] = function($str) {
    return function() use ($str) {
        $res = \in_array('xxh64', hash_algos()) ? hash('xxh64', $str) : hash('sha256', $str);
        
        // Return a duck-typed Promise to satisfy Effect (Promise String) FFI contract
        return new class($res) {
            private $val;
            public function __construct($val) { $this->val = $val; }
            public function then($k, $c = null) {
                $res = $k($this->val);
                // If the callback returns an Effect (closure), execute it to fulfill the PureScript Aff trampoline.
                if (\is_callable($res)) {
                    $res();
                }
                return $this;
            }
            public function catch($c) { return $this; }
            public function finally($f) { return $this; }
        };
    };
};

$exports['hmacSha256'] = function($secret, $message = null) {
    if (\func_num_args() < 2) {
        return function($message) use ($secret) {
            global $exports;
            return $exports['hmacSha256']($secret, $message);
        };
    }
    return hash_hmac('sha256', $message, $secret);
};

return $exports;
