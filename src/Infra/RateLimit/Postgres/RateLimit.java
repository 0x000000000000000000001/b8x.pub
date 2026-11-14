    // Port of RateLimit.js: fixed-window counter in the rate_limit table
    // (key varchar primary key, points integer, expire bigint milliseconds).
    private static final String __rateLimitSql =
        "INSERT INTO rate_limit (key, points, expire) VALUES ($1, 1, $2) " +
        "ON CONFLICT (key) DO UPDATE SET " +
        "points = CASE WHEN rate_limit.expire <= $3 THEN 1 ELSE rate_limit.points + 1 END, " +
        "expire = CASE WHEN rate_limit.expire <= $3 THEN $2 ELSE rate_limit.expire END " +
        "RETURNING points";

    public static Object _consume = (java.util.function.Function<Object, Object>) (client) ->
        (java.util.function.Function<Object, Object>) (key) ->
        (java.util.function.Function<Object, Object>) (points) ->
        (java.util.function.Function<Object, Object>) (durationSec) ->
        (java.util.function.Supplier<Object>) () -> {
            try {
                long now = System.currentTimeMillis();
                long expire = now + ((Number) durationSec).longValue() * 1000L;
                Object[] params = { key, (double) expire, (double) now };
                Object effect = ((java.util.function.Function<Object, Object>)
                    ((java.util.function.Function<Object, Object>)
                        ((java.util.function.Function<Object, Object>) __M$Infra_Client_Postgres_Postgres._query)
                            .apply(client))
                        .apply(__rateLimitSql))
                    .apply(params);
                Object promise = ((java.util.function.Supplier<Object>) effect).get();
                __M$Promise_Internal.PromiseValue settled = (__M$Promise_Internal.PromiseValue) promise;
                if (settled.failed) throw new RuntimeException(String.valueOf(settled.rejection));
                Object[] rows = (Object[]) settled.value;
                if (rows.length == 0) {
                    return ((java.util.function.Function<Object, Object>) __M$Promise_Internal.resolve).apply(false);
                }
                double used = ((Number) ((java.util.Map<String, Object>) rows[0]).get("points")).doubleValue();
                return ((java.util.function.Function<Object, Object>) __M$Promise_Internal.resolve)
                    .apply(used <= ((Number) points).doubleValue());
            } catch (Throwable failure) {
                return ((java.util.function.Function<Object, Object>) __M$Promise_Internal.reject)
                    .apply(failure.getMessage() == null ? failure.toString() : failure.getMessage());
            }
        };
