<?php

$removeAccents = function($str) {
    if (class_exists('Transliterator')) {
        $transliterator = \Transliterator::create('Any-Latin; Latin-ASCII; [\u0300-\u036f] remove');
        if ($transliterator !== null) {
            return $transliterator->transliterate($str);
        }
    }
    return iconv('UTF-8', 'ASCII//TRANSLIT//IGNORE', $str);
};

$upperCaseFirst = function($str) {
    if ($str === "") return "";
    return mb_strtoupper(mb_substr($str, 0, 1)) . mb_substr($str, 1);
};

$lowerCaseFirst = function($str) {
    if ($str === "") return "";
    return mb_strtolower(mb_substr($str, 0, 1)) . mb_substr($str, 1);
};

$exports['removeAccents'] = $removeAccents;
$exports['upperCaseFirst'] = $upperCaseFirst;
$exports['lowerCaseFirst'] = $lowerCaseFirst;
return $exports;
