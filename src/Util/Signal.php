<?php

$exports['onSignalImpl'] = function ($signal, $callback) {
    $signalNumber = match ($signal) {
        'SIGINT' => SIGINT,
        'SIGTERM' => SIGTERM,
        'SIGQUIT' => SIGQUIT,
        default => null,
    };

    if (
        $signalNumber !== null &&
        function_exists('pcntl_async_signals') &&
        function_exists('pcntl_signal')
    ) {
        pcntl_async_signals(true);
        pcntl_signal($signalNumber, static function () use ($callback): void {
            $callback();
        });
    }
};

return $exports;
