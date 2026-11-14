    // Port of Instant.js. JavaScript dates are epoch milliseconds; the JVM
    // side formats them with java.time, Europe/Paris for the French variants.
    private static final java.time.ZoneId __instantParis = java.time.ZoneId.of("Europe/Paris");
    private static final java.time.format.DateTimeFormatter __instantIso =
        java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'");
    private static final java.time.format.DateTimeFormatter __instantHuman =
        java.time.format.DateTimeFormatter.ofPattern("d MMMM yyyy 'à' HH:mm", java.util.Locale.FRENCH);
    private static final java.time.format.DateTimeFormatter __instantSendy =
        java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss", java.util.Locale.FRENCH);

    private static String __instantIsoString(double milliseconds) {
        return java.time.Instant.ofEpochMilli((long) milliseconds)
            .atOffset(java.time.ZoneOffset.UTC)
            .format(__instantIso);
    }

    public static Object _toIsoString = (java.util.function.Function<Object, Object>) (milliseconds) ->
        __instantIsoString(((Number) milliseconds).doubleValue());

    public static Object _toHumanParisDate = (java.util.function.Function<Object, Object>) (milliseconds) ->
        java.time.Instant.ofEpochMilli(((Number) milliseconds).longValue())
            .atZone(__instantParis)
            .format(__instantHuman);

    public static Object _toSendyScheduleDate = (java.util.function.Function<Object, Object>) (milliseconds) ->
        java.time.Instant.ofEpochMilli(((Number) milliseconds).longValue())
            .atZone(__instantParis)
            .format(__instantSendy);

    public static Object _parseIsoString = (java.util.function.Function<Object, Object>) (just) ->
        (java.util.function.Function<Object, Object>) (nothing) ->
        (java.util.function.Function<Object, Object>) (input) -> {
            String text = (String) input;
            try {
                return ((java.util.function.Function<Object, Object>) just)
                    .apply((double) java.time.Instant.parse(text).toEpochMilli());
            } catch (java.time.format.DateTimeParseException ignored) {
            }
            try {
                return ((java.util.function.Function<Object, Object>) just)
                    .apply((double) java.time.OffsetDateTime.parse(text).toInstant().toEpochMilli());
            } catch (java.time.format.DateTimeParseException ignored) {
            }
            try {
                return ((java.util.function.Function<Object, Object>) just)
                    .apply((double) java.time.LocalDateTime.parse(text).toInstant(java.time.ZoneOffset.UTC).toEpochMilli());
            } catch (java.time.format.DateTimeParseException ignored) {
            }
            return ((java.util.function.Function<Object, Object>) nothing).apply(null);
        };

    public static Object _parseParisTime = (java.util.function.Function<Object, Object>) (just) ->
        (java.util.function.Function<Object, Object>) (nothing) ->
        (java.util.function.Function<Object, Object>) (year) ->
        (java.util.function.Function<Object, Object>) (month) ->
        (java.util.function.Function<Object, Object>) (day) ->
        (java.util.function.Function<Object, Object>) (hour) ->
        (java.util.function.Function<Object, Object>) (minute) -> {
            try {
                java.time.ZonedDateTime time = java.time.ZonedDateTime.of(
                    ((Number) year).intValue(), ((Number) month).intValue(), ((Number) day).intValue(),
                    ((Number) hour).intValue(), ((Number) minute).intValue(), 0, 0, __instantParis);
                return ((java.util.function.Function<Object, Object>) just)
                    .apply(__instantIsoString((double) time.toInstant().toEpochMilli()));
            } catch (java.time.DateTimeException failure) {
                return ((java.util.function.Function<Object, Object>) nothing).apply(null);
            }
        };
