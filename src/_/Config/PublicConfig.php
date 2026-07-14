<?php

$exports['_publicConfig'] = (object) [
  'env' => getenv('ENV'),
  'version' => getenv('GIT_COMMIT'),
  'api' => (object) [
    'host' => getenv('API_DNS_LEVEL_3_GTE'),
  ],
  'ui' => (object) [
    'host' => getenv('DNS_LEVEL_2_GTE'),
    'dns' => (object) [
      'level1' => getenv('DNS_LEVEL_1'),
      'level2' => (object) [
        'a' => getenv('DNS_LEVEL_2_a'),
        'b' => getenv('DNS_LEVEL_2_b')
      ]
    ],
    'legacyHost' => getenv('LEGACY_DNS_LEVEL_2_GTE'),
    'appId' => getenv('UI_APP_ID')
  ],
  'objectStorage' => (object) [
    'urlBase' => getenv('S3_URL_BASE'),
  ]
];

return $exports;
