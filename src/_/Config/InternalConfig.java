    // Port of InternalConfig.js. The JavaScript placeholders are substituted
    // at build time; on the JVM the values come from the process environment,
    // which is what the container provides.
    private static String __env(String name, String fallback) {
        String value = System.getenv(name);
        return value == null ? fallback : value;
    }

    private static Double __envInt(String name, int fallback) {
        String value = System.getenv(name);
        if (value == null || value.isEmpty()) return (double) fallback;
        try {
            return Double.parseDouble(value);
        } catch (NumberFormatException ignored) {
            return (double) fallback;
        }
    }

    private static java.util.Map<String, Object> __dbSubConfig(String hostName, String databaseName, int idleDefault) {
        java.util.Map<String, Object> config = new java.util.LinkedHashMap<>();
        config.put("host", __env(hostName, ""));
        config.put("directHost", __env("POSTGRES_HOST", ""));
        config.put("port", __envInt("POSTGRES_PORT", 5432));
        config.put("database", __env(databaseName, ""));
        config.put("user", __env("POSTGRES_USER", ""));
        config.put("password", __env("POSTGRES_PASSWORD", ""));
        config.put("idleTimeoutMs", __envInt("POSTGRES_IDLE_TIMEOUT_MS", idleDefault));
        return config;
    }

    public static Object _config = __internalConfig();

    private static Object __internalConfig() {
        java.util.Map<String, Object> config = new java.util.LinkedHashMap<>();

        java.util.Map<String, Object> db = new java.util.LinkedHashMap<>();
        db.put("store", __dbSubConfig("POSTGRES_HOST_STORE", "POSTGRES_DB_STORE", 30000));
        db.put("storeLock", __dbSubConfig("POSTGRES_HOST_STORE_LOCK", "POSTGRES_DB_STORE", 2000));
        db.put("edge", __dbSubConfig("POSTGRES_HOST_EDGE", "POSTGRES_DB_EDGE", 30000));
        config.put("db", db);

        java.util.Map<String, Object> mq = new java.util.LinkedHashMap<>();
        mq.put("host", __env("RABBITMQ_HOST", ""));
        mq.put("port", __envInt("RABBITMQ_PORT", 5672));
        mq.put("user", __env("RABBITMQ_USER", ""));
        mq.put("password", __env("RABBITMQ_PASS", ""));
        config.put("mq", mq);

        java.util.Map<String, Object> mail = new java.util.LinkedHashMap<>();
        java.util.Map<String, Object> mailFrom = new java.util.LinkedHashMap<>();
        mailFrom.put("name", __env("MAIL_FROM_NAME", ""));
        java.util.Map<String, Object> mailFromEmail = new java.util.LinkedHashMap<>();
        mailFromEmail.put("transaction", __env("MAIL_FROM_TRANSACTION_EMAIL", ""));
        mailFromEmail.put("bug", __env("MAIL_FROM_BUG_EMAIL", ""));
        mailFromEmail.put("newsletter", __env("MAIL_FROM_NEWSLETTER_EMAIL", ""));
        mailFrom.put("email", mailFromEmail);
        mail.put("from", mailFrom);
        java.util.Map<String, Object> mailTo = new java.util.LinkedHashMap<>();
        mailTo.put("bug", __env("MAIL_TO_BUG_EMAIL", ""));
        mail.put("to", mailTo);
        config.put("mail", mail);

        java.util.Map<String, Object> helloAsso = new java.util.LinkedHashMap<>();
        helloAsso.put("clientId", __env("HELLOASSO_CLIENT_ID", ""));
        helloAsso.put("clientSecret", __env("HELLOASSO_CLIENT_SECRET", ""));
        helloAsso.put("webhookSecret", __env("HELLOASSO_WEBHOOK_SECRET", ""));
        config.put("helloAsso", helloAsso);

        java.util.Map<String, Object> aws = new java.util.LinkedHashMap<>();
        String region = __env("AWS_REGION", "");
        aws.put("region", region);
        java.util.Map<String, Object> ses = new java.util.LinkedHashMap<>();
        ses.put("region", region);
        ses.put("accessKeyId", __env("SES_ACCESS_KEY", ""));
        ses.put("secretAccessKey", __env("SES_SECRET_ACCESS_KEY", ""));
        aws.put("ses", ses);
        java.util.Map<String, Object> s3 = new java.util.LinkedHashMap<>();
        s3.put("region", region);
        s3.put("bucket", __env("S3_BUCKET", ""));
        s3.put("accessKeyId", __env("S3_ACCESS_KEY", ""));
        s3.put("secretAccessKey", __env("S3_SECRET_ACCESS_KEY", ""));
        s3.put("urlBase", __env("S3_URL_BASE", ""));
        aws.put("s3", s3);
        config.put("aws", aws);

        java.util.Map<String, Object> sendy = new java.util.LinkedHashMap<>();
        sendy.put("licenseKey", __env("SENDY_LICENSE_KEY", ""));
        java.util.Map<String, Object> sendyAws = new java.util.LinkedHashMap<>();
        sendyAws.put("accessKeyId", __env("SENDY_AWS_IAM_KEY", ""));
        sendyAws.put("secretAccessKey", __env("SENDY_AWS_IAM_SECRET", ""));
        sendy.put("awsIam", sendyAws);
        sendy.put("user", __env("SENDY_USER", ""));
        sendy.put("password", __env("SENDY_PASSWORD", ""));
        sendy.put("apiKey", __env("SENDY_API_KEY", ""));
        sendy.put("brandId", __env("SENDY_BRAND_ID", ""));
        sendy.put("listId", __env("SENDY_LIST_ID", ""));
        sendy.put("host", __env("NEWS_DNS_LEVEL_3_GTE", ""));
        config.put("sendy", sendy);

        java.util.Map<String, Object> auth = new java.util.LinkedHashMap<>();
        auth.put("pasetoLocalKey", __env("AUTH_PASETO_LOCAL_KEY", ""));
        config.put("auth", auth);

        java.util.Map<String, Object> mailchimp = new java.util.LinkedHashMap<>();
        mailchimp.put("apiKey", __env("MAILCHIMP_API_KEY", ""));
        mailchimp.put("masterDraftId", __env("MAILCHIMP_MASTER_DRAFT_ID", ""));
        mailchimp.put("serverPrefix", __env("MAILCHIMP_SERVER_PREFIX", ""));
        config.put("mailchimp", mailchimp);

        return config;
    }
