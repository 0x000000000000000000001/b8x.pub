    // Port of Signal.js. The JVM has no POSIX listener API here; the effect
    // runs as a shutdown hook, which is the only signal the process handles.
    public static Object onSignalImpl = (java.util.function.Function<Object, Object>) (signal) ->
        (java.util.function.Function<Object, Object>) (effect) ->
        (java.util.function.Supplier<Object>) () -> {
            Runtime.getRuntime().addShutdownHook(new Thread(() -> {
                ((java.util.function.Supplier<Object>) effect).get();
            }));
            return null;
        };
