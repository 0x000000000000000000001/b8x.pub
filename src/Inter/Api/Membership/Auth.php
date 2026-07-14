<?php

return [
    'appendHeaderImpl' => function($name) {
        return function($value) use ($name) {
            return function($res) use ($name, $value) {
                return function() use ($name, $value, $res) {
                    if (!isset($res->headers[$name])) {
                        $res->headers[$name] = $value;
                    } else {
                        if (is_array($res->headers[$name])) {
                            $res->headers[$name][] = $value;
                        } else {
                            $res->headers[$name] = [$res->headers[$name], $value];
                        }
                    }
                };
            };
        };
    },
    'nowIso' => function() {
        return function() {
            return (new \DateTime())->format('Y-m-d\TH:i:s.v\Z');
        };
    }
];
