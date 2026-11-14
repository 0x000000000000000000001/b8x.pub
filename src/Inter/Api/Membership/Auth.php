<?php

return [
    'appendHeaderImpl' => function($name, $value, $res) {
        if (!isset($res->headers[$name])) {
            $res->headers[$name] = $value;
        } else {
            if (is_array($res->headers[$name])) {
                $res->headers[$name][] = $value;
            } else {
                $res->headers[$name] = [$res->headers[$name], $value];
            }
        }
    },
    'nowIso' => function() {
        return (new \DateTimeImmutable('now', new \DateTimeZone('UTC')))->format('Y-m-d\TH:i:s.v\Z');
    }
];
