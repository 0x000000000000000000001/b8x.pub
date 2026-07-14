<?php

$_generateUlid = function() {
    return strtolower((new \Symfony\Component\Uid\Ulid())->toBase32());
};

$_isValid = function($ulid) {
    return \Symfony\Component\Uid\Ulid::isValid($ulid);
};

$exports['_generateUlid'] = $_generateUlid;
$exports['_isValid'] = $_isValid;

return $exports;
