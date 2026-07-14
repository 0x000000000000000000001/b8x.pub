<?php

$exports['parse'] = function($str) {
    $cookies = [];
    $parts = explode(';', $str);
    foreach ($parts as $part) {
        $kv = explode('=', trim($part), 2);
        if (\count($kv) === 2) {
            $cookies[$kv[0]] = urldecode($kv[1]);
        }
    }
    return (object)$cookies;
};

$exports['serializeImpl'] = function($name, $val = null, $options = null) {
    if (\func_num_args() < 3) {
        $__args = \func_get_args();
        return function(...$more) use ($__args) {
            global $exports;
            return $exports['serializeImpl'](...\array_merge($__args, $more));
        };
    }
    
    $str = urlencode($name) . '=' . urlencode($val);
    if (isset($options->maxAge)) $str .= '; Max-Age=' . $options->maxAge;
    if (isset($options->domain)) $str .= '; Domain=' . $options->domain;
    if (isset($options->path)) $str .= '; Path=' . $options->path;
    if (isset($options->expires)) $str .= '; Expires=' . $options->expires;
    if (isset($options->httpOnly) && $options->httpOnly) $str .= '; HttpOnly';
    if (isset($options->secure) && $options->secure) $str .= '; Secure';
    if (isset($options->sameSite)) $str .= '; SameSite=' . $options->sameSite;
    
    return $str;
};

return $exports;
