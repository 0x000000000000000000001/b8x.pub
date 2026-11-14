<?php

$exports['setIntervalImpl'] = function ($ms, $callback) {
    return \Revolt\EventLoop::repeat($ms / 1000, static function () use ($callback): void {
        $callback();
    });
};

$exports['clearIntervalImpl'] = function ($id) {
    \Revolt\EventLoop::cancel($id);
};

return $exports;
