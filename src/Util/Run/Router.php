<?php

$exports['empty'] = [];

$exports['_on'] = function($tag) {
    return function($handler) use ($tag) {
        return function($dict) use ($tag, $handler) {
            $newDict = $dict;
            $newDict[$tag] = $handler;
            return $newDict;
        };
    };
};

$exports['build'] = function($dict) {
    return function($fallback) use ($dict) {
        return function($variant) use ($dict, $fallback) {
            $handler = $dict[$variant->type] ?? null;
            if ($handler !== null) {
                return $handler($variant->value);
            }
            return $fallback($variant);
        };
    };
};
