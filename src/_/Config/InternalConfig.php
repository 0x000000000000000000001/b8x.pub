<?php

$exports['_config'] = (object) [
  'name' => getenv('APP_NAME'),
  'db' => (object) [
    'store' => (object) [
      'host' => getenv('POSTGRES_HOST_STORE'),
      'directHost' => getenv('POSTGRES_HOST'),
      'port' => (int) getenv('POSTGRES_PORT'),
      'database' => getenv('POSTGRES_DB_STORE'),
      'user' => getenv('POSTGRES_USER'),
      'password' => getenv('POSTGRES_PASSWORD'),
      'idleTimeoutMs' => (int) (getenv('POSTGRES_IDLE_TIMEOUT_MS') ?: 10000)
    ],
    'storeLock' => (object) [
      'host' => getenv('POSTGRES_HOST_STORE_LOCK'),
      'directHost' => getenv('POSTGRES_HOST'),
      'port' => (int) getenv('POSTGRES_PORT'),
      'database' => getenv('POSTGRES_DB_STORE'),
      'user' => getenv('POSTGRES_USER'),
      'password' => getenv('POSTGRES_PASSWORD'),
      'idleTimeoutMs' => (int) (getenv('POSTGRES_IDLE_TIMEOUT_MS') ?: 2000)
    ],
    'edge' => (object) [
      'host' => getenv('POSTGRES_HOST_EDGE'),
      'directHost' => getenv('POSTGRES_HOST'),
      'port' => (int) getenv('POSTGRES_PORT'),
      'database' => getenv('POSTGRES_DB_EDGE'),
      'user' => getenv('POSTGRES_USER'),
      'password' => getenv('POSTGRES_PASSWORD'),
      'idleTimeoutMs' => (int) (getenv('POSTGRES_IDLE_TIMEOUT_MS') ?: 10000)
    ],
  ],
  'mq' => (object) [
    'host' => getenv('RABBITMQ_HOST'),
    'port' => (int) getenv('RABBITMQ_PORT'),
    'user' => getenv('RABBITMQ_USER'),
    'password' => getenv('RABBITMQ_PASS'),
  ],
  'mail' => (object) [
    'from' => (object) [
      'name' => getenv('MAIL_FROM_NAME'),
      'email' => (object) [
        'transaction' => getenv('MAIL_FROM_TRANSACTION_EMAIL'),
        'bug' => getenv('MAIL_FROM_BUG_EMAIL'),
        'newsletter' => getenv('MAIL_FROM_NEWSLETTER_EMAIL'),
      ]
    ]
  ],
  'helloAsso' => (object) [
    'clientId' => getenv('HELLOASSO_CLIENT_ID'),
    'clientSecret' => getenv('HELLOASSO_CLIENT_SECRET'),
    'webhookSecret' => getenv('HELLOASSO_WEBHOOK_SECRET')
  ],
  'aws' => (object) [
    'region' => getenv('AWS_REGION'),
    'ses' => (object) [
      'region' => getenv('AWS_REGION'),
      'accessKeyId' => getenv('SES_ACCESS_KEY'),
      'secretAccessKey' => getenv('SES_SECRET_ACCESS_KEY'), 
    ],
    's3' => (object) [
      'region' => getenv('AWS_REGION'),
      'bucket' => getenv('S3_BUCKET'),
      'accessKeyId' => getenv('S3_ACCESS_KEY'),
      'secretAccessKey' => getenv('S3_SECRET_ACCESS_KEY'),
      'urlBase' => getenv('S3_URL_BASE')
    ]
  ],
  'sendy' => (object) [
    'licenseKey' => getenv('SENDY_LICENSE_KEY'),
    'awsIam' => (object) [
      'accessKeyId' => getenv('SENDY_AWS_IAM_KEY'),
      'secretAccessKey' => getenv('SENDY_AWS_IAM_SECRET'), 
    ],
    'user' => getenv('SENDY_USER'),
    'password' => getenv('SENDY_PASSWORD'),
    'apiKey' => getenv('SENDY_API_KEY'),
    'brandId' => getenv('SENDY_BRAND_ID'),
    'listId' => getenv('SENDY_LIST_ID'),
    'host' => getenv('NEWS_DNS_LEVEL_3_GTE')
  ],
  'auth' => (object) [
    'pasetoLocalKey' => getenv('AUTH_PASETO_LOCAL_KEY')
  ],
  'mailchimp' => (object) [
    'apiKey' => getenv('MAILCHIMP_API_KEY'),
    'masterDraftId' => getenv('MAILCHIMP_MASTER_DRAFT_ID'),
    'serverPrefix' => getenv('MAILCHIMP_SERVER_PREFIX')
  ]
];

return $exports;
