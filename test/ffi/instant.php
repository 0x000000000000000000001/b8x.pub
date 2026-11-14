<?php

function instantCheck(bool $condition, string $message): void
{
    if (!$condition) {
        throw new RuntimeException($message);
    }
}

$exports = [];
$instant = require dirname(__DIR__, 2) . '/src/Core/Mod/Time/Instant.php';

$just = static fn($value) => ['just' => $value];
$nothing = ['nothing' => true];
$parseParisTime = $instant['_parseParisTime'];

instantCheck(is_callable($parseParisTime), 'Missing _parseParisTime export');

// Same expectations as Core/Mod/Time/Instant.js, checked on the JavaScript target.
$cases = [
    [2026, 7, 15, 14, 30, '2026-07-15T12:30:00.000Z'],
    [2026, 1, 15, 14, 30, '2026-01-15T13:30:00.000Z'],
    [2026, 3, 29, 1, 30, '2026-03-28T23:30:00.000Z'],
    [2026, 3, 29, 2, 30, '2026-03-29T00:30:00.000Z'],
    [2026, 10, 25, 1, 30, '2026-10-25T00:30:00.000Z'],
    [2026, 10, 25, 2, 30, '2026-10-25T01:30:00.000Z'],
    [2026, 2, 31, 10, 0, '2026-03-03T09:00:00.000Z'],
    [2026, 2, 29, 10, 0, '2026-03-01T09:00:00.000Z'],
    [2024, 2, 29, 10, 0, '2024-02-29T09:00:00.000Z'],
    [2026, 12, 31, 23, 59, '2026-12-31T22:59:00.000Z'],
];

foreach ($cases as [$year, $month, $day, $hour, $minute, $expected]) {
    instantCheck(
        $parseParisTime($just, $nothing, $year, $month, $day, $hour, $minute) === $just($expected),
        sprintf('Wrong Paris time for %04d-%02d-%02d %02d:%02d', $year, $month, $day, $hour, $minute),
    );
}

foreach ([[2026, 13, 1, 0, 0], [2026, 0, 10, 0, 0], [2026, 1, 0, 0, 0], [2026, 1, 1, 10, 60]] as $invalid) {
    instantCheck(
        $parseParisTime($just, $nothing, ...$invalid) === $nothing,
        'Invalid date must return Nothing',
    );
}

// JavaScript TimeClip truncates towards zero, including for negative instants.
$toIsoString = $instant['_toIsoString'];
foreach ([
    [0, '1970-01-01T00:00:00.000Z'],
    [1500.9, '1970-01-01T00:00:01.500Z'],
    [-1000, '1969-12-31T23:59:59.000Z'],
    [-1500, '1969-12-31T23:59:58.500Z'],
    [-0.9, '1970-01-01T00:00:00.000Z'],
] as [$ms, $expected]) {
    instantCheck($toIsoString($ms) === $expected, sprintf('Wrong ISO string for %s ms', $ms));
}

// Date.parse parity for the ECMAScript date/time format, with the same
// Europe/Paris timezone as the JavaScript target.
$parseIsoString = $instant['_parseIsoString'];
$previousTimezone = date_default_timezone_get();
date_default_timezone_set('Europe/Paris');
try {
    foreach ([
        '2026-01-15' => 1768435200000,
        '2026-01-15T10:00:00' => 1768467600000,
        '2026-01-15T10:00:00Z' => 1768471200000,
        '2026-01-15T10:00:00+02:00' => 1768464000000,
        '2026-01-15T10:00' => 1768467600000,
        '2026-01-15T10:00:00.123Z' => 1768471200123,
        '2026-01-15 10:00:00' => 1768467600000,
        '2026-02-31T10:00:00Z' => 1772532000000,
        '2026-01-15T10:00:00+0200' => 1768464000000,
    ] as $input => $expected) {
        instantCheck(
            $parseIsoString($just, $nothing, $input) === $just($expected),
            sprintf('Wrong parse for %s', $input),
        );
    }
} finally {
    date_default_timezone_set($previousTimezone);
}
foreach (['now', '+1 day', '2026-13-01', 'not a date', ''] as $invalid) {
    instantCheck(
        $parseIsoString($just, $nothing, $invalid) === $nothing,
        sprintf('Invalid ISO input must return Nothing: %s', $invalid),
    );
}

echo "Instant PHP FFI checks passed\n";
