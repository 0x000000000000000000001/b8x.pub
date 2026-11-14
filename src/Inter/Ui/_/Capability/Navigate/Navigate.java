    // Port of Navigate.js. There is no browser history in the JVM process;
    // keep the hook inert.
    public static Object _dispatchPopStateEvent = (java.util.function.Supplier<Object>) () -> null;
