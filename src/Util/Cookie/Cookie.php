<?php

$exports['parse'] = function($str) {
    $cookies = [];
    foreach (explode(';', $str) as $part) {
        $kv = explode('=', $part, 2);
        if (\count($kv) !== 2) {
            continue;
        }
        $cookies[trim($kv[0])] = rawurldecode(trim($kv[1]));
    }
    return $cookies;
};

$exports['serializeImpl'] = function($name, $val, $maxAge, $httpOnly, $path, $secure, $sameSite, $domain) {
    $str = rawurlencode($name) . '=' . rawurlencode($val);

    $str .= '; Max-Age=' . $maxAge;
    if ($domain !== '') {
        $str .= '; Domain=' . $domain;
    }
    if ($path !== '') {
        $str .= '; Path=' . $path;
    }
    if ($httpOnly) {
        $str .= '; HttpOnly';
    }
    if ($secure) {
        $str .= '; Secure';
    }
    if ($sameSite !== '') {
        $str .= '; SameSite=' . ucfirst(strtolower($sameSite));
    }

    return $str;
};

return $exports;
