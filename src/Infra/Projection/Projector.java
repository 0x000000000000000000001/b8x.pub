    // Java's EffectFn representation is curried and keeps the terminal Supplier.
    private static Object __projectorAttempt(java.util.function.Supplier<Object> action) {
        return (java.util.function.Function<Object, Object>) onError ->
            (java.util.function.Function<Object, Object>) onSuccess ->
            (java.util.function.Supplier<Object>) () -> {
                Object result;
                try {
                    result = action.get();
                } catch (Throwable failure) {
                    Object message = failure.getMessage() == null ? failure.toString() : failure.getMessage();
                    ((java.util.function.Supplier<?>) ((java.util.function.Function<Object, Object>) onError).apply(message)).get();
                    return __projectorNonCanceler();
                }
                ((java.util.function.Supplier<?>) ((java.util.function.Function<Object, Object>) onSuccess).apply(result)).get();
                return __projectorNonCanceler();
            };
    }

    private static Object __projectorNonCanceler() {
        return (java.util.function.Function<Object, Object>) reason ->
            (java.util.function.Function<Object, Object>) onError ->
            (java.util.function.Function<Object, Object>) onSuccess ->
            (java.util.function.Supplier<Object>) () ->
                ((java.util.function.Supplier<?>) ((java.util.function.Function<Object, Object>) onSuccess).apply(null)).get();
    }

    // Port of Projector.js: hold a dedicated JDBC connection with a session
    // advisory lock; the connection stays referenced for the process lifetime.
    private static final java.util.Map<String, java.sql.Connection> __projectorLocks =
        new java.util.concurrent.ConcurrentHashMap<>();

    public static Object _tryAdvisoryLock = (java.util.function.Function<Object, Object>) (host) ->
        (java.util.function.Function<Object, Object>) (port) ->
        (java.util.function.Function<Object, Object>) (database) ->
        (java.util.function.Function<Object, Object>) (user) ->
        (java.util.function.Function<Object, Object>) (password) ->
        (java.util.function.Function<Object, Object>) (lockName) ->
        __projectorAttempt(() -> {
            String key = java.util.Base64.getEncoder().encodeToString(
                (host + "|" + port + "|" + database + "|" + user + "|" + lockName)
                    .getBytes(java.nio.charset.StandardCharsets.UTF_8));
            if (__projectorLocks.containsKey(key)) {
                return false;
            }
            try {
                java.sql.Connection connection = java.sql.DriverManager.getConnection(
                    "jdbc:postgresql://" + host + ":" + ((Number) port).intValue() + "/" + database,
                    (String) user, (String) password);
                try (java.sql.PreparedStatement statement = connection.prepareStatement(
                        "SELECT pg_try_advisory_lock(hashtext(?)) as locked")) {
                    statement.setString(1, "proj:" + lockName);
                    try (java.sql.ResultSet resultSet = statement.executeQuery()) {
                        resultSet.next();
                        if (resultSet.getBoolean("locked")) {
                            __projectorLocks.put(key, connection);
                            return true;
                        }
                    }
                }
                connection.close();
                return false;
            } catch (Throwable failure) {
                throw new RuntimeException(failure);
            }
        });
