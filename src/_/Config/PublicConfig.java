    // Port of PublicConfig.js. The JavaScript placeholders are substituted at
    // build time; on the JVM the values come from the process environment,
    // which is what the container provides.
    private static String __publicEnv(String name, String fallback) {
        String value = System.getenv(name);
        return value == null || value.isEmpty() ? fallback : value;
    }

    public static Object _publicConfig = __publicConfig();

    private static Object __publicConfig() {
        java.util.Map<String, Object> config = new java.util.LinkedHashMap<>();
        config.put("env", __publicEnv("ENV", "dev"));
        config.put("version", __publicEnv("GIT_COMMIT", "unknown"));

        java.util.Map<String, Object> api = new java.util.LinkedHashMap<>();
        api.put("host", __publicEnv("API_DNS_LEVEL_3_GTE", ""));
        api.put("port", __publicEnv("API_DEFAULT_PORT", __publicEnv("DNS_DEFAULT_PORT", "")));
        api.put("scheme", __publicEnv("API_DEFAULT_SCHEME", __publicEnv("DNS_DEFAULT_SCHEME", "http")));
        config.put("api", api);

        java.util.Map<String, Object> dnsLevel2 = new java.util.LinkedHashMap<>();
        dnsLevel2.put("a", __publicEnv("DNS_LEVEL_2_a", ""));
        dnsLevel2.put("b", __publicEnv("DNS_LEVEL_2_b", ""));
        java.util.Map<String, Object> dns = new java.util.LinkedHashMap<>();
        dns.put("level1", __publicEnv("DNS_LEVEL_1", ""));
        dns.put("level2", dnsLevel2);
        java.util.Map<String, Object> ui = new java.util.LinkedHashMap<>();
        ui.put("host", __publicEnv("DNS_LEVEL_2_GTE", ""));
        ui.put("dns", dns);
        ui.put("legacyHost", __publicEnv("LEGACY_DNS_LEVEL_2_GTE", ""));
        ui.put("appId", __publicEnv("UI_APP_ID", ""));
        config.put("ui", ui);

        java.util.Map<String, Object> objectStorage = new java.util.LinkedHashMap<>();
        objectStorage.put("urlBase", __publicEnv("S3_URL_BASE", ""));
        config.put("objectStorage", objectStorage);

        return config;
    }
