    // Port of KeepAlive.js: hold the JVM open while the process waits on
    // server-side effects. The JavaScript version keeps a never-firing
    // interval; the equivalent is one non-daemon thread parked forever.
    private static final Object __keepAliveLock = new Object();
    private static boolean __keepAliveStarted = false;

    public static Object keepMainAlive = (java.util.function.Supplier<Object>) () -> {
        synchronized (__keepAliveLock) {
            if (__keepAliveStarted) return null;
            __keepAliveStarted = true;
        }
        Thread keeper = new Thread(() -> {
            try {
                Thread.sleep(Long.MAX_VALUE);
            } catch (InterruptedException interrupted) {
                Thread.currentThread().interrupt();
            }
        }, "keep-main-alive");
        keeper.setDaemon(false);
        keeper.start();
        return null;
    };
