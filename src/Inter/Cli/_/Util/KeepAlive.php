<?php

$exports['keepMainAlive'] = function() {
    // Match the referenced interval in KeepAlive.js; PHPurs runs Revolt after main.
    \Revolt\EventLoop::repeat(10.0, static function() {});
    return null;
};

return $exports;
