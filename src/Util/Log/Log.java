    // Port of Log.js.
    public static Object _write = (java.util.function.Function<Object, Object>) (input) ->
        (java.util.function.Supplier<Object>) () -> {
            System.out.print((String) input);
            System.out.flush();
            return null;
        };
