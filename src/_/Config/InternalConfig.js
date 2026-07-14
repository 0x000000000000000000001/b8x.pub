export const _config = {
  db: {
    store: {
      host: "$POSTGRES_HOST_STORE",
      directHost: "$POSTGRES_HOST",
      port: parseInt("$POSTGRES_PORT"),
      database: "$POSTGRES_DB_STORE",
      user: "$POSTGRES_USER",
      password: "$POSTGRES_PASSWORD",
      idleTimeoutMs: parseInt("$POSTGRES_IDLE_TIMEOUT_MS" || "30000")
    },
    storeLock: {
      host: "$POSTGRES_HOST_STORE_LOCK",
      directHost: "$POSTGRES_HOST",
      port: parseInt("$POSTGRES_PORT"),
      database: "$POSTGRES_DB_STORE",
      user: "$POSTGRES_USER",
      password: "$POSTGRES_PASSWORD",
      idleTimeoutMs: parseInt("$POSTGRES_IDLE_TIMEOUT_MS" || "2000")
    },
    edge: {
      host: "$POSTGRES_HOST_EDGE",
      directHost: "$POSTGRES_HOST",
      port: parseInt("$POSTGRES_PORT"),
      database: "$POSTGRES_DB_EDGE",
      user: "$POSTGRES_USER",
      password: "$POSTGRES_PASSWORD",
      idleTimeoutMs: parseInt("$POSTGRES_IDLE_TIMEOUT_MS" || "30000")
    },
  },
  mq: {
    host: "$RABBITMQ_HOST",
    port: parseInt("$RABBITMQ_PORT"),
    user: "$RABBITMQ_USER",
    password: "$RABBITMQ_PASS",
  },
  mail: {
    from: {
      name: "$MAIL_FROM_NAME",
      email: {
        transaction: "$MAIL_FROM_TRANSACTION_EMAIL",
        bug: "$MAIL_FROM_BUG_EMAIL",
        newsletter: "$MAIL_FROM_NEWSLETTER_EMAIL",
      }
    }
  },
  helloAsso: {
    clientId: "$HELLOASSO_CLIENT_ID",
    clientSecret: "$HELLOASSO_CLIENT_SECRET",
    webhookSecret: "$HELLOASSO_WEBHOOK_SECRET"
  },
  aws: {
    region: "$AWS_REGION",
    ses: {
      region: "$AWS_REGION",
      accessKeyId: "$SES_ACCESS_KEY",
      secretAccessKey: "$SES_SECRET_ACCESS_KEY", 
    },
    s3: {
      region: "$AWS_REGION",
      bucket: "$S3_BUCKET",
      accessKeyId: "$S3_ACCESS_KEY",
      secretAccessKey: "$S3_SECRET_ACCESS_KEY",
      urlBase: "$S3_URL_BASE"
    }
  },
  sendy: {
    licenseKey: "$SENDY_LICENSE_KEY",
    awsIam: {
      accessKeyId: "$SENDY_AWS_IAM_KEY",
      secretAccessKey: "$SENDY_AWS_IAM_SECRET", 
    },
    user: "$SENDY_USER",
    password: "$SENDY_PASSWORD",
    apiKey: "$SENDY_API_KEY",
    brandId: "$SENDY_BRAND_ID",
    listId: "$SENDY_LIST_ID",
    host: "$NEWS_DNS_LEVEL_3_GTE"
  },
  auth: {
    pasetoLocalKey: "$AUTH_PASETO_LOCAL_KEY"
  },
  mailchimp: {
    apiKey: "$MAILCHIMP_API_KEY",
    masterDraftId: "$MAILCHIMP_MASTER_DRAFT_ID",
    serverPrefix: "$MAILCHIMP_SERVER_PREFIX"
  }
};
