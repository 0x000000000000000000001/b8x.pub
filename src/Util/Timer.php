<?php

$_setInterval = function($ms, $fn = null) use (&$_setInterval) {
    if (\func_num_args() < 2) {
        return function($fn) use ($ms, &$_setInterval) {
            return $_setInterval($ms, $fn);
        };
    }
    return function() use ($ms, $fn) {
        return \Revolt\EventLoop::repeat($ms / 1000, function() use ($fn) {
            $fn(); // Execute the Effect
        });
    };
};

$exports['_setInterval'] = $_setInterval;

$exports['_clearInterval'] = function($id) {
    return function() use ($id) {
        \Revolt\EventLoop::cancel($id);
    };
};

return $exports;
