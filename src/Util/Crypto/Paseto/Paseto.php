<?php

$exports['encryptV3LocalImpl'] = function($keyStr, $payload = null, $expiresInStr = null) {
    if (\func_num_args() < 3) {
        $__args = \func_get_args();
        return function(...$more) use ($__args) {
            global $exports;
            return $exports['encryptV3LocalImpl'](...\array_merge($__args, $more));
        };
    }
    return function() use ($keyStr, $payload, $expiresInStr) {
        return (object)[
            'then' => function($resolve, $reject) use ($keyStr, $payload, $expiresInStr) {
                try {
                    $sharedKey = new \ParagonIE\Paseto\Keys\SymmetricKey(hex2bin($keyStr), new \ParagonIE\Paseto\Protocol\Version3());
                    $builder = \ParagonIE\Paseto\Builder::getLocal(new \ParagonIE\Paseto\Protocol\Version3(), $sharedKey);
                    
                    // Convert stdClass/array payload to claims
                    foreach ((array)$payload as $k => $v) {
                        $builder->set($k, $v);
                    }
                    
                    // Simple parsing of expiresInStr (e.g. '2h', '7d')
                    if (preg_match('/^(\d+)([hdm])$/', $expiresInStr, $matches)) {
                        $val = $matches[1];
                        $unit = $matches[2] === 'h' ? 'hours' : ($matches[2] === 'd' ? 'days' : 'minutes');
                        $builder->setExpiration((new \DateTime())->modify("+$val $unit"));
                    }
                    
                    $token = $builder->toString();
                    $resolve($token)();
                } catch (\Throwable $e) {
                    $reject($e)();
                }
            }
        ];
    };
};

$exports['decryptV3LocalImpl'] = function($keyStr, $token = null) {
    if (\func_num_args() < 2) {
        $__args = \func_get_args();
        return function(...$more) use ($__args) {
            global $exports;
            return $exports['decryptV3LocalImpl'](...\array_merge($__args, $more));
        };
    }
    return function() use ($keyStr, $token) {
        return (object)[
            'then' => function($resolve, $reject) use ($keyStr, $token) {
                try {
                    $sharedKey = new \ParagonIE\Paseto\Keys\SymmetricKey(hex2bin($keyStr), new \ParagonIE\Paseto\Protocol\Version3());
                    $parser = \ParagonIE\Paseto\Parser::getLocal(new \ParagonIE\Paseto\Protocol\Version3(), $sharedKey);
                    $tokenObj = $parser->parse($token);
                    $resolve((object)$tokenObj->getClaims())();
                } catch (\Throwable $e) {
                    $reject($e)();
                }
            }
        ];
    };
};

return $exports;
