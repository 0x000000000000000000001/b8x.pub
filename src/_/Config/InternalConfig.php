<?php

// getenv() returns false for an unset variable, which would leak a boolean into
// a PureScript record of String fields.
$env = static fn(string $name): string => getenv($name) === false ? '' : getenv($name);
$envInt = static fn(string $name, int $default): int => $env($name) === '' ? $default : (int) $env($name);

$exports['_config'] = [
    'name' => $env('APP_NAME'),
    'db' => [
        'store' => [
            'host' => $env('POSTGRES_HOST_STORE'),
            'directHost' => $env('POSTGRES_HOST'),
            'port' => $envInt('POSTGRES_PORT', 0),
            'database' => $env('POSTGRES_DB_STORE'),
            'user' => $env('POSTGRES_USER'),
            'password' => $env('POSTGRES_PASSWORD'),
            'idleTimeoutMs' => $envInt('POSTGRES_IDLE_TIMEOUT_MS', 10000),
        ],
        'storeLock' => [
            'host' => $env('POSTGRES_HOST_STORE_LOCK'),
            'directHost' => $env('POSTGRES_HOST'),
            'port' => $envInt('POSTGRES_PORT', 0),
            'database' => $env('POSTGRES_DB_STORE'),
            'user' => $env('POSTGRES_USER'),
            'password' => $env('POSTGRES_PASSWORD'),
            'idleTimeoutMs' => $envInt('POSTGRES_IDLE_TIMEOUT_MS', 2000),
        ],
        'edge' => [
            'host' => $env('POSTGRES_HOST_EDGE'),
            'directHost' => $env('POSTGRES_HOST'),
            'port' => $envInt('POSTGRES_PORT', 0),
            'database' => $env('POSTGRES_DB_EDGE'),
            'user' => $env('POSTGRES_USER'),
            'password' => $env('POSTGRES_PASSWORD'),
            'idleTimeoutMs' => $envInt('POSTGRES_IDLE_TIMEOUT_MS', 10000),
        ],
    ],
    'mq' => [
        'host' => $env('RABBITMQ_HOST'),
        'port' => $envInt('RABBITMQ_PORT', 0),
        'user' => $env('RABBITMQ_USER'),
        'password' => $env('RABBITMQ_PASS'),
    ],
    'mail' => [
        'from' => [
            'name' => $env('MAIL_FROM_NAME'),
            'email' => [
                'transaction' => $env('MAIL_FROM_TRANSACTION_EMAIL'),
                'bug' => $env('MAIL_FROM_BUG_EMAIL'),
                'newsletter' => $env('MAIL_FROM_NEWSLETTER_EMAIL'),
            ],
        ],
        'to' => [
            'bug' => $env('MAIL_TO_BUG_EMAIL'),
        ],
    ],
    'helloAsso' => [
        'clientId' => $env('HELLOASSO_CLIENT_ID'),
        'clientSecret' => $env('HELLOASSO_CLIENT_SECRET'),
        'webhookSecret' => $env('HELLOASSO_WEBHOOK_SECRET'),
    ],
    'aws' => [
        'region' => $env('AWS_REGION'),
        'ses' => [
            'region' => $env('AWS_REGION'),
            'accessKeyId' => $env('SES_ACCESS_KEY'),
            'secretAccessKey' => $env('SES_SECRET_ACCESS_KEY'),
        ],
        's3' => [
            'region' => $env('AWS_REGION'),
            'bucket' => $env('S3_BUCKET'),
            'accessKeyId' => $env('S3_ACCESS_KEY'),
            'secretAccessKey' => $env('S3_SECRET_ACCESS_KEY'),
            'urlBase' => $env('S3_URL_BASE'),
        ],
    ],
    'sendy' => [
        'licenseKey' => $env('SENDY_LICENSE_KEY'),
        'awsIam' => [
            'accessKeyId' => $env('SENDY_AWS_IAM_KEY'),
            'secretAccessKey' => $env('SENDY_AWS_IAM_SECRET'),
        ],
        'user' => $env('SENDY_USER'),
        'password' => $env('SENDY_PASSWORD'),
        'apiKey' => $env('SENDY_API_KEY'),
        'brandId' => $env('SENDY_BRAND_ID'),
        'listId' => $env('SENDY_LIST_ID'),
        'host' => $env('NEWS_DNS_LEVEL_3_GTE'),
    ],
    'auth' => [
        'pasetoLocalKey' => $env('AUTH_PASETO_LOCAL_KEY'),
    ],
    'mailchimp' => [
        'apiKey' => $env('MAILCHIMP_API_KEY'),
        'masterDraftId' => $env('MAILCHIMP_MASTER_DRAFT_ID'),
        'serverPrefix' => $env('MAILCHIMP_SERVER_PREFIX'),
    ],
];

return $exports;
