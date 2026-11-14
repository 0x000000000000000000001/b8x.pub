<?php

$exports['parseJSONImpl'] = function($left, $right, $str) {
    $decoded = \json_decode($str);
    if (\json_last_error() !== JSON_ERROR_NONE) {
        return $left(\json_last_error_msg());
    }
    return $right($decoded);
};

return $exports;
