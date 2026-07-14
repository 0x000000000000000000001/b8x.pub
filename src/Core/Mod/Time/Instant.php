<?php

$exports = [];

$exports['_parseIsoString'] = function($just) {
    return function($nothing) use ($just) {
        return function($str) use ($just, $nothing) {
            $t = strtotime($str);
            if ($t === false) {
                return $nothing;
            }
            try {
                $dt = new \DateTime($str);
                $ms = (float)$dt->format('U.u') * 1000;
                return $just($ms);
            } catch (\Exception $e) {
                return $nothing;
            }
        };
    };
};

$exports['_toIsoString'] = function($ms) {
    // Note: ms might be float
    $sec = floor($ms / 1000);
    $msec = $ms - ($sec * 1000);
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
