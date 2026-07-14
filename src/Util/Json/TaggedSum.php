<?php

$exports['fixTaggedSumRepMissingValue'] = function($f) {
    if (is_object($f) && isset($f->type) && is_string($f->type) && !property_exists($f, 'value')) {
        $clone = clone $f;
        $clone->value = null;
        return $clone;
    }
    if (is_array($f) && isset($f['type']) && is_string($f['type']) && !array_key_exists('value', $f)) {
        $clone = $f;
        $clone['value'] = null;
        return $clone;
    }
    return $f;
};

return $exports;
