// Configuration FFI for Config.InternalConfig (Sharpurs).
// The JS template is interpolated at build time; the F# backend follows the
// Go, PHP and Rust backends and reads the same environment variables at
// runtime. Records are Map<string, obj> and Int values are boxed Int32.

let private configEnv (name: string) : obj =
    match System.Environment.GetEnvironmentVariable(name) with
    | null -> box ""
    | value -> box value

let private configInt (name: string) (fallback: int) : obj =
    let raw = System.Environment.GetEnvironmentVariable(name)

    if System.String.IsNullOrEmpty(raw) then
        box fallback
    else
        match System.Int32.TryParse(raw) with
        | true, value -> box value
        | _ -> box fallback

let private configRecord (fields: (string * obj) list) : obj =
    box (Map.ofList fields)

let private configDb (hostVar: string) (databaseVar: string) (idleFallback: int) : obj =
    configRecord
        [ "host", configEnv hostVar
          "directHost", configEnv "POSTGRES_HOST"
          "port", configInt "POSTGRES_PORT" 0
          "database", configEnv databaseVar
          "user", configEnv "POSTGRES_USER"
          "password", configEnv "POSTGRES_PASSWORD"
          "idleTimeoutMs", configInt "POSTGRES_IDLE_TIMEOUT_MS" idleFallback ]

let private configAws (region: obj) : obj =
    configRecord
        [ "region", region
          "ses",
          configRecord
              [ "region", region
                "accessKeyId", configEnv "SES_ACCESS_KEY"
                "secretAccessKey", configEnv "SES_SECRET_ACCESS_KEY" ]
          "s3",
          configRecord
              [ "region", region
                "bucket", configEnv "S3_BUCKET"
                "accessKeyId", configEnv "S3_ACCESS_KEY"
                "secretAccessKey", configEnv "S3_SECRET_ACCESS_KEY"
                "urlBase", configEnv "S3_URL_BASE" ] ]

let _config : obj =
    let region = configEnv "AWS_REGION"

    configRecord
        [ "name", configEnv "APP_NAME"
          "db",
          configRecord
              [ "store", configDb "POSTGRES_HOST_STORE" "POSTGRES_DB_STORE" 30000
                "storeLock", configDb "POSTGRES_HOST_STORE_LOCK" "POSTGRES_DB_STORE" 2000
                "edge", configDb "POSTGRES_HOST_EDGE" "POSTGRES_DB_EDGE" 30000 ]
          "mq",
          configRecord
              [ "host", configEnv "RABBITMQ_HOST"
                "port", configInt "RABBITMQ_PORT" 0
                "user", configEnv "RABBITMQ_USER"
                "password", configEnv "RABBITMQ_PASS" ]
          "mail",
          configRecord
              [ "from",
                configRecord
                    [ "name", configEnv "MAIL_FROM_NAME"
                      "email",
                      configRecord
                          [ "transaction", configEnv "MAIL_FROM_TRANSACTION_EMAIL"
                            "bug", configEnv "MAIL_FROM_BUG_EMAIL"
                            "newsletter", configEnv "MAIL_FROM_NEWSLETTER_EMAIL" ] ]
                "to", configRecord [ "bug", configEnv "MAIL_TO_BUG_EMAIL" ] ]
          "helloAsso",
          configRecord
              [ "clientId", configEnv "HELLOASSO_CLIENT_ID"
                "clientSecret", configEnv "HELLOASSO_CLIENT_SECRET"
                "webhookSecret", configEnv "HELLOASSO_WEBHOOK_SECRET" ]
          "aws", configAws region
          "sendy",
          configRecord
              [ "licenseKey", configEnv "SENDY_LICENSE_KEY"
                "awsIam",
                configRecord
                    [ "accessKeyId", configEnv "SENDY_AWS_IAM_KEY"
                      "secretAccessKey", configEnv "SENDY_AWS_IAM_SECRET" ]
                "user", configEnv "SENDY_USER"
                "password", configEnv "SENDY_PASSWORD"
                "apiKey", configEnv "SENDY_API_KEY"
                "brandId", configEnv "SENDY_BRAND_ID"
                "listId", configEnv "SENDY_LIST_ID"
                "host", configEnv "NEWS_DNS_LEVEL_3_GTE" ]
          "auth", configRecord [ "pasetoLocalKey", configEnv "AUTH_PASETO_LOCAL_KEY" ]
          "mailchimp",
          configRecord
              [ "apiKey", configEnv "MAILCHIMP_API_KEY"
                "masterDraftId", configEnv "MAILCHIMP_MASTER_DRAFT_ID"
                "serverPrefix", configEnv "MAILCHIMP_SERVER_PREFIX" ] ]
