<?php

$env = static fn(string $name): string => getenv($name) === false ? '' : getenv($name);

$exports['_publicConfig'] = [
    'env' => $env('ENV'),
    'version' => $env('GIT_COMMIT'),
    'api' => [
        'host' => $env('API_DNS_LEVEL_3_GTE'),
    ],
    'ui' => [
        'host' => $env('DNS_LEVEL_2_GTE'),
        'dns' => [
            'level1' => $env('DNS_LEVEL_1'),
            'level2' => [
                'a' => $env('DNS_LEVEL_2_a'),
                'b' => $env('DNS_LEVEL_2_b'),
            ],
        ],
        'legacyHost' => $env('LEGACY_DNS_LEVEL_2_GTE'),
        'appId' => $env('UI_APP_ID'),
    ],
    'objectStorage' => [
        'urlBase' => $env('S3_URL_BASE'),
    ],
];

return $exports;
