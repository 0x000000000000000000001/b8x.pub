<?php

require dirname(__DIR__, 2) . '/run/bak/php/vendor/autoload.php';

function effectsCheck(bool $condition, string $message): void
{
    if (!$condition) {
        throw new RuntimeException($message);
    }
}

$exports = [];
$effect = require dirname(__DIR__, 3) . '/phpurs/phpurs-effect/src/Effect/Uncurried.php';
$exports = [];
$timer = require dirname(__DIR__, 2) . '/src/Util/Timer.php';
$exports = [];
$signal = require dirname(__DIR__, 2) . '/src/Util/Signal.php';
$auth = require dirname(__DIR__, 2) . '/src/Inter/Api/Membership/Auth.php';

$identifiers = Revolt\EventLoop::getIdentifiers();
$calls = 0;
$interval = null;
$timeout = null;
$start = $effect['runEffectFn2']($timer['setIntervalImpl'], 1, function (...$arguments) use (
    &$calls,
    &$interval,
    &$timeout,
    $timer,
) {
    effectsCheck($arguments === [], 'Effect timer callback received native arguments');
    $calls++;
    $timer['clearIntervalImpl']($interval);
    Revolt\EventLoop::cancel($timeout);
    return (object) ['unit' => true];
});
effectsCheck(
    Revolt\EventLoop::getIdentifiers() === $identifiers,
    'Timer registered before its Effect ran',
);
$interval = $start();
$timeout = Revolt\EventLoop::delay(1, fn() => throw new RuntimeException('Timer failed to fire'));
try {
    Revolt\EventLoop::run();
    effectsCheck($calls === 1, 'Timer callback did not run exactly once');
} finally {
    Revolt\EventLoop::cancel($interval);
    Revolt\EventLoop::cancel($timeout);
}
$interval = $timer['setIntervalImpl'](
    1000,
    fn() => throw new RuntimeException('Cancelled timer ran'),
);
$clear = $effect['runEffectFn1']($timer['clearIntervalImpl'], $interval);
effectsCheck(in_array($interval, Revolt\EventLoop::getIdentifiers()), 'Clear effect ran early');
$clear();
effectsCheck(
    !in_array($interval, Revolt\EventLoop::getIdentifiers()),
    'Clear effect left timer registered',
);

if (function_exists('pcntl_signal_get_handler')) {
    $previousHandler = pcntl_signal_get_handler(SIGINT);
    $previousAsync = pcntl_async_signals();
    $signalCalls = 0;
    try {
        $handler = function (...$arguments) use (&$signalCalls) {
            effectsCheck($arguments === [], 'Effect signal callback received native arguments');
            $signalCalls++;
            return (object) ['unit' => true];
        };
        $register = $effect['runEffectFn2']($signal['onSignalImpl'], 'SIGINT', $handler);
        effectsCheck(
            pcntl_signal_get_handler(SIGINT) === $previousHandler,
            'Signal handler registered early',
        );
        $register();
        effectsCheck(
            is_callable(pcntl_signal_get_handler(SIGINT)),
            'Signal handler was not registered',
        );
        effectsCheck(
            pcntl_signal_get_handler(SIGINT)(SIGINT) === null,
            'Signal callback must discard the Effect result',
        );
        effectsCheck($signalCalls === 1, 'Signal callback did not execute');
    } finally {
        pcntl_signal(SIGINT, $previousHandler);
        pcntl_async_signals($previousAsync);
    }
}
$response = (object) ['headers' => []];
$append = $effect['runEffectFn3']($auth['appendHeaderImpl'], 'Set-Cookie', 'one=1', $response);
effectsCheck($response->headers === [], 'Header append ran before its Effect');
$append();
$auth['appendHeaderImpl']('Set-Cookie', 'two=2', $response);
$auth['appendHeaderImpl']('Set-Cookie', 'three=3', $response);
effectsCheck(
    $response->headers['Set-Cookie'] === ['one=1', 'two=2', 'three=3'],
    'Header append lost earlier values',
);
$previousTimezone = date_default_timezone_get();
try {
    date_default_timezone_set('Pacific/Honolulu');
    $timestamp = $auth['nowIso']();
    effectsCheck(
        is_string($timestamp) &&
            preg_match('/^\d{4}-\d\d-\d\dT\d\d:\d\d:\d\d\.\d{3}Z$/', $timestamp) === 1,
        'nowIso must return an ISO string',
    );
    effectsCheck(
        abs(new DateTimeImmutable($timestamp)->getTimestamp() - time()) <= 1,
        'nowIso must use UTC',
    );
} finally {
    date_default_timezone_set($previousTimezone);
}
echo "Effect PHP FFI checks passed\n";
