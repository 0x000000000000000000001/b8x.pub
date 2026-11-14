<?php

$exports['empty'] = [];

$exports['_on'] = function($tag, $handler, $dict) {
    $newDict = $dict;
    $newDict[$tag] = $handler;
    return $newDict;
};

$exports['_build'] = function($dict, $fallback, $tag, $value, $original) {
    $handler = $dict[$tag] ?? null;
    if ($handler !== null) {
        return $handler($value);
    }
    return $fallback($original);
};
