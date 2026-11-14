<?php

$exports = [];

$exports['_parseIsoString'] = function($just, $nothing, $str) {
    // Accept the ECMAScript date/time format only: Date.parse otherwise takes
    // relative strings ("now", "+1 day") that an ISO parser must reject.
    if (
        !preg_match(
            '/^(\d{4})-(\d{2})-(\d{2})(?:[Tt ](\d{2}):(\d{2})(?::(\d{2})(?:\.(\d{1,6}))?)?([Zz]|[+-]\d{2}:?\d{2})?)?$/',
            $str,
            $matches,
        )
    ) {
        return $nothing;
    }

    $year = (int) $matches[1];
    $month = (int) $matches[2];
    $day = (int) $matches[3];
    $hasTime = isset($matches[4]);
    $hour = $hasTime ? (int) $matches[4] : 0;
    $minute = $hasTime ? (int) $matches[5] : 0;
    $second = isset($matches[6]) ? (int) $matches[6] : 0;
    $fraction = isset($matches[7]) ? substr($matches[7], 0, 3) : '';
    $millisecond = (int) str_pad($fraction, 3, '0');

    if (
        $month < 1 || $month > 12 ||
        $day < 1 || $day > 31 ||
        $hour > 23 || $minute > 59 || $second > 59
    ) {
        return $nothing;
    }

    $offset = $matches[8] ?? '';
    if (strtoupper($offset) === 'Z') {
        $offset = 'Z';
    } elseif (!$hasTime) {
        // Date.parse reads a bare date as UTC.
        $offset = 'Z';
    }

    try {
        $instant = new \DateTimeImmutable(
            sprintf(
                '%04d-%02d-%02dT%02d:%02d:%02d.%03d%s',
                $year,
                $month,
                $day,
                $hour,
                $minute,
                $second,
                $millisecond,
                $offset,
            ),
            new \DateTimeZone(date_default_timezone_get()),
        );
    } catch (\Throwable $error) {
        return $nothing;
    }

    return $just((int) $instant->format('U') * 1000 + (int) $instant->format('v'));
};

$exports['_parseParisTime'] = function($just, $nothing, $year, $month, $day, $hour, $minute) {
    // Same algorithm as Instant.js: read the Paris offset at the instant formed
    // by the wall-clock fields taken as UTC, then resolve the wall clock with it.
    if (
        $month < 1 || $month > 12 ||
        $day < 1 || $day > 31 ||
        $hour < 0 || $hour > 23 ||
        $minute < 0 || $minute > 59
    ) {
        return $nothing;
    }

    $wallClock = sprintf('%04d-%02d-%02dT%02d:%02d:00', $year, $month, $day, $hour, $minute);

    try {
        $asUtc = new \DateTimeImmutable($wallClock . 'Z', new \DateTimeZone('UTC'));
        $offset = $asUtc->setTimezone(new \DateTimeZone('Europe/Paris'))->getOffset();
        $offsetString = sprintf(
            '%s%02d:%02d',
            $offset < 0 ? '-' : '+',
            intdiv(abs($offset), 3600),
            intdiv(abs($offset) % 3600, 60),
        );
        // Invalid days (e.g. 31 February) roll over, as in JavaScript.
        $instant = new \DateTimeImmutable($wallClock . $offsetString);
    } catch (\Throwable $error) {
        return $nothing;
    }

    return $just($instant->setTimezone(new \DateTimeZone('UTC'))->format('Y-m-d\TH:i:s.v\Z'));
};

$exports['_toIsoString'] = function($ms) {
    // JavaScript TimeClip truncates towards zero; keep the same millisecond.
    $totalMs = (int) $ms;
    $sec = \intdiv($totalMs, 1000);
    $msec = $totalMs % 1000;
    if ($msec < 0) {
        $sec--;
        $msec += 1000;
    }
    $dt = new \DateTime("@$sec");
    return $dt->format('Y-m-d\TH:i:s') . sprintf('.%03dZ', $msec);
};

$exports['_toHumanParisDate'] = function($ms) {
    $sec = floor($ms / 1000);
    $dt = new \DateTime("@$sec");
    $dt->setTimezone(new \DateTimeZone('Europe/Paris'));
    
    // We would need IntlDateFormatter for exactly matching the JS output:
    // 'numeric' year, 'long' month, 'numeric' day, '2-digit' hour and minute.
    if (class_exists('IntlDateFormatter')) {
        $fmt = new \IntlDateFormatter(
            'fr_FR',
            \IntlDateFormatter::LONG,
            \IntlDateFormatter::SHORT,
            'Europe/Paris',
            \IntlDateFormatter::GREGORIAN,
            "d MMMM y 'à' HH:mm"
        );
        return str_replace(' à ', ' ', $fmt->format($dt));
    }
    
    // Fallback if no intl extension
    $months = [
        1 => 'janvier', 2 => 'février', 3 => 'mars', 4 => 'avril',
        5 => 'mai', 6 => 'juin', 7 => 'juillet', 8 => 'août',
        9 => 'septembre', 10 => 'octobre', 11 => 'novembre', 12 => 'décembre'
    ];
    return $dt->format('j') . ' ' . $months[(int)$dt->format('n')] . ' ' . $dt->format('Y H:i');
};

$exports['_toSendyScheduleDate'] = function($ms) {
    $sec = floor($ms / 1000);
    $dt = new \DateTime("@$sec");
    $dt->setTimezone(new \DateTimeZone('Europe/Paris'));
    return $dt->format('Y-m-d H:i:s');
};

return $exports;
