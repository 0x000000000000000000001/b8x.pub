use purust_core::Value as ConfigValue;

fn config_record(fields: &[(&str, ConfigValue)]) -> ConfigValue {
    let mut result = purust_core::RecordFields::new();
    for (name, value) in fields {
        result.insert((*name).to_owned(), value.clone());
    }
    ConfigValue::DynamicRecord(perceus_ptr::PerceusPtr::new(result))
}
fn config_env(name: &str) -> ConfigValue {
    ConfigValue::String(purust_core::purust_string_from_utf8(
        &std::env::var(name).unwrap_or_default(),
    ))
}
fn config_int(name: &str, fallback: i64) -> ConfigValue {
    let input = std::env::var(name).unwrap_or_default();
    let value = if input.is_empty() {
        fallback
    } else {
        input
            .parse()
            .unwrap_or_else(|_| panic!("Invalid integer configuration: {}", name))
    };
    ConfigValue::Int(value)
}
fn config_db(host: &str, database: &str, idle: i64) -> ConfigValue {
    config_record(&[
        ("host", config_env(host)),
        ("directHost", config_env("POSTGRES_HOST")),
        ("port", config_int("POSTGRES_PORT", 0)),
        ("database", config_env(database)),
        ("user", config_env("POSTGRES_USER")),
        ("password", config_env("POSTGRES_PASSWORD")),
        (
            "idleTimeoutMs",
            config_int("POSTGRES_IDLE_TIMEOUT_MS", idle),
        ),
    ])
}
pub fn Config_InternalConfig__config() -> crate::UnknownType {
    thread_local! { static CONFIG: std::cell::OnceCell<ConfigValue> = const { std::cell::OnceCell::new() }; }
    CONFIG.with(|config| config.get_or_init(config_build).clone())
}
fn config_build() -> ConfigValue {
    // APP_NAME follows the existing Go FFI; timeout defaults follow the JS template.
    config_record(&[
        ("name", config_env("APP_NAME")),
        (
            "db",
            config_record(&[
                (
                    "store",
                    config_db("POSTGRES_HOST_STORE", "POSTGRES_DB_STORE", 30000),
                ),
                (
                    "storeLock",
                    config_db("POSTGRES_HOST_STORE_LOCK", "POSTGRES_DB_STORE", 2000),
                ),
                (
                    "edge",
                    config_db("POSTGRES_HOST_EDGE", "POSTGRES_DB_EDGE", 30000),
                ),
            ]),
        ),
        (
            "mq",
            config_record(&[
                ("host", config_env("RABBITMQ_HOST")),
                ("port", config_int("RABBITMQ_PORT", 0)),
                ("user", config_env("RABBITMQ_USER")),
                ("password", config_env("RABBITMQ_PASS")),
            ]),
        ),
        (
            "mail",
            config_record(&[
                (
                    "from",
                    config_record(&[
                        ("name", config_env("MAIL_FROM_NAME")),
                        (
                            "email",
                            config_record(&[
                                ("transaction", config_env("MAIL_FROM_TRANSACTION_EMAIL")),
                                ("bug", config_env("MAIL_FROM_BUG_EMAIL")),
                                ("newsletter", config_env("MAIL_FROM_NEWSLETTER_EMAIL")),
                            ]),
                        ),
                    ]),
                ),
                (
                    "to",
                    config_record(&[("bug", config_env("MAIL_TO_BUG_EMAIL"))]),
                ),
            ]),
        ),
        (
            "helloAsso",
            config_record(&[
                ("clientId", config_env("HELLOASSO_CLIENT_ID")),
                ("clientSecret", config_env("HELLOASSO_CLIENT_SECRET")),
                ("webhookSecret", config_env("HELLOASSO_WEBHOOK_SECRET")),
            ]),
        ),
        (
            "aws",
            config_record(&[
                ("region", config_env("AWS_REGION")),
                (
                    "ses",
                    config_record(&[
                        ("region", config_env("AWS_REGION")),
                        ("accessKeyId", config_env("SES_ACCESS_KEY")),
                        ("secretAccessKey", config_env("SES_SECRET_ACCESS_KEY")),
                    ]),
                ),
                (
                    "s3",
                    config_record(&[
                        ("region", config_env("AWS_REGION")),
                        ("bucket", config_env("S3_BUCKET")),
                        ("accessKeyId", config_env("S3_ACCESS_KEY")),
                        ("secretAccessKey", config_env("S3_SECRET_ACCESS_KEY")),
                        ("urlBase", config_env("S3_URL_BASE")),
                    ]),
                ),
            ]),
        ),
        (
            "sendy",
            config_record(&[
                ("licenseKey", config_env("SENDY_LICENSE_KEY")),
                (
                    "awsIam",
                    config_record(&[
                        ("accessKeyId", config_env("SENDY_AWS_IAM_KEY")),
                        ("secretAccessKey", config_env("SENDY_AWS_IAM_SECRET")),
                    ]),
                ),
                ("user", config_env("SENDY_USER")),
                ("password", config_env("SENDY_PASSWORD")),
                ("apiKey", config_env("SENDY_API_KEY")),
                ("brandId", config_env("SENDY_BRAND_ID")),
                ("listId", config_env("SENDY_LIST_ID")),
                ("host", config_env("NEWS_DNS_LEVEL_3_GTE")),
            ]),
        ),
        (
            "auth",
            config_record(&[("pasetoLocalKey", config_env("AUTH_PASETO_LOCAL_KEY"))]),
        ),
        (
            "mailchimp",
            config_record(&[
                ("apiKey", config_env("MAILCHIMP_API_KEY")),
                ("masterDraftId", config_env("MAILCHIMP_MASTER_DRAFT_ID")),
                ("serverPrefix", config_env("MAILCHIMP_SERVER_PREFIX")),
            ]),
        ),
    ])
}
