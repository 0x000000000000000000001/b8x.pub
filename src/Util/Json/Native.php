<?php

$exports['parseJSONImpl'] = function($left) {
    return function($right) use ($left) {
        return function($str) use ($left, $right) {
            $decoded = \json_decode($str);
            if (\json_last_error() !== JSON_ERROR_NONE) {
                return $left(\json_last_error_msg());
            }
            return $right($decoded);
        };
    };
};

return $exports;
