<?php

$_decodeHtmlEntities = function($str) {
    return html_entity_decode($str, ENT_QUOTES | ENT_HTML5, 'UTF-8');
};

$_encodeHtmlEntities = function($str) {
    $encoded = '';
    for ($i = 0, $len = mb_strlen($str, 'UTF-8'); $i < $len; $i++) {
        $char = mb_substr($str, $i, 1, 'UTF-8');
        if (preg_match('/[a-zA-Z0-9\s]/', $char)) {
            $encoded .= $char;
        } else {
            $encoded .= '&#' . 'x' . strtoupper(dechex(mb_ord($char, 'UTF-8'))) . ';';
        }
    }
    return $encoded;
};

$exports['_decodeHtmlEntities'] = $_decodeHtmlEntities;
$exports['_encodeHtmlEntities'] = $_encodeHtmlEntities;
return $exports;
