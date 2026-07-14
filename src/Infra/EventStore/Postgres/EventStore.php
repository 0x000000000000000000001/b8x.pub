<?php

$cco_process_id = str_pad((string)rand(0, 999), 3, '0', STR_PAD_LEFT);
$cco_counter = 0;

$exports['generateLockKeyStr'] = function() use (&$cco_process_id, &$cco_counter) {
    $cco_counter = ($cco_counter + 1) % 1000;
    $counterStr = str_pad((string)$cco_counter, 3, '0', STR_PAD_LEFT);
    $timeMs = (string)floor(microtime(true) * 1000);
    return $timeMs . $cco_process_id . $counterStr;
};

return $exports;
