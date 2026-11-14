    // Port of EventStore.js lock key generator: wall clock, a per-process id
    // and a cycling counter.
    private static final int __lockKeyProcessId = new java.util.Random().nextInt(1000);
    private static int __lockKeyCounter = 0;

    public static Object generateLockKeyStr = (java.util.function.Supplier<Object>) () -> {
        __lockKeyCounter = (__lockKeyCounter + 1) % 1000;
        return System.currentTimeMillis()
            + String.format("%03d", __lockKeyProcessId)
            + String.format("%03d", __lockKeyCounter);
    };
