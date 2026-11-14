<?php

$exports['encryptV3LocalImpl'] = static function ($keyHex, $payload, $expiresIn) {
    return static function ($onError, $onSuccess) use ($keyHex, $payload, $expiresIn) {
        $cancel = static fn($reason, $onCancelerError, $onCancelerSuccess) => $onCancelerSuccess(
            null,
        );
        try {
            $protocol = new \ParagonIE\Paseto\Protocol\Version3();
            $sharedKey = new \ParagonIE\Paseto\Keys\SymmetricKey(hex2bin($keyHex), $protocol);
            $builder = \ParagonIE\Paseto\Builder::getLocal($sharedKey, $protocol);
            foreach ((array) $payload as $claim => $value) {
                $builder->set($claim, $value);
            }
            if (preg_match('/^(\d+)([hdm])$/', $expiresIn, $matches)) {
                $duration = $matches[1];
                $unit = match ($matches[2]) {
                    'h' => 'hours',
                    'd' => 'days',
                    'm' => 'minutes',
                };
                $builder->setExpiration(new \DateTime()->modify("+$duration $unit"));
            }
            $token = $builder->toString();
        } catch (\Throwable $failure) {
            $onError($failure);
            return $cancel;
        }
        $onSuccess($token);
        return $cancel;
    };
};

$exports['decryptV3LocalImpl'] = static function ($keyHex, $token) {
    return static function ($onError, $onSuccess) use ($keyHex, $token) {
        $cancel = static fn($reason, $onCancelerError, $onCancelerSuccess) => $onCancelerSuccess(
            null,
        );
        try {
            $protocol = new \ParagonIE\Paseto\Protocol\Version3();
            $sharedKey = new \ParagonIE\Paseto\Keys\SymmetricKey(hex2bin($keyHex), $protocol);
            $parser = \ParagonIE\Paseto\Parser::getLocal(
                $sharedKey,
                new \ParagonIE\Paseto\ProtocolCollection($protocol),
            );
            $claims = $parser->parse($token)->getClaims();
        } catch (\Throwable $failure) {
            $onError($failure);
            return $cancel;
        }
        $onSuccess($claims);
        return $cancel;
    };
};

return $exports;
