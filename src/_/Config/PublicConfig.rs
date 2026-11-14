use purust_core::Value as PublicConfigValue;

fn public_env(key: &str) -> PublicConfigValue {
    PublicConfigValue::String(purust_core::purust_string_from_utf8(
        &std::env::var(key).unwrap_or_default(),
    ))
}
fn public_record(fields: &[(&str, PublicConfigValue)]) -> PublicConfigValue {
    let mut record = purust_core::RecordFields::new();
    for (key, value) in fields {
        record.insert((*key).to_owned(), value.clone());
    }
    PublicConfigValue::DynamicRecord(perceus_ptr::PerceusPtr::new(record))
}
pub fn Config_PublicConfig__publicConfig() -> crate::UnknownType {
    thread_local! { static CONFIG: std::cell::OnceCell<PublicConfigValue> = const { std::cell::OnceCell::new() }; }
    CONFIG.with(|config| {
        config
            .get_or_init(|| {
                public_record(&[
                    ("env", public_env("ENV")),
                    ("version", public_env("GIT_COMMIT")),
                    (
                        "api",
                        public_record(&[("host", public_env("API_DNS_LEVEL_3_GTE"))]),
                    ),
                    (
                        "ui",
                        public_record(&[
                            ("host", public_env("DNS_LEVEL_2_GTE")),
                            (
                                "dns",
                                public_record(&[
                                    ("level1", public_env("DNS_LEVEL_1")),
                                    (
                                        "level2",
                                        public_record(&[
                                            ("a", public_env("DNS_LEVEL_2_a")),
                                            ("b", public_env("DNS_LEVEL_2_b")),
                                        ]),
                                    ),
                                ]),
                            ),
                            ("legacyHost", public_env("LEGACY_DNS_LEVEL_2_GTE")),
                            ("appId", public_env("UI_APP_ID")),
                        ]),
                    ),
                    (
                        "objectStorage",
                        public_record(&[("urlBase", public_env("S3_URL_BASE"))]),
                    ),
                ])
            })
            .clone()
    })
}
