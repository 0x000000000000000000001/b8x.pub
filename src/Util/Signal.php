<?php

$exports['_onSignal'] = function($signal) {
    return function($callback) use ($signal) {
        return function() use ($signal, $callback) {
            $signo = null;
            if ($signal === "SIGINT") $signo = SIGINT;
            if ($signal === "SIGTERM") $signo = SIGTERM;
            if ($signal === "SIGQUIT") $signo = SIGQUIT;

            if ($signo !== null && function_exists('pcntl_async_signals') && function_exists('pcntl_signal')) {
                pcntl_async_signals(true);
                pcntl_signal($signo, function() use ($callback) {
                    $callback();
                });
            }
        };
    };
};

return $exports;
