    // Port of Hash.js. MD5/SHA-256/HMAC come from the JDK; XXH-64 is the
    // standard 64-bit variant implemented locally (the JS side uses
    // xxhash-wasm).
    private static String __hashHex(byte[] bytes) {
        StringBuilder out = new StringBuilder(bytes.length * 2);
        for (byte value : bytes) out.append(String.format("%02x", value & 0xff));
        return out.toString();
    }

    private static byte[] __hashDigest(String algorithm, byte[] input) {
        try {
            return java.security.MessageDigest.getInstance(algorithm).digest(input);
        } catch (java.security.NoSuchAlgorithmException failure) {
            throw new RuntimeException(failure);
        }
    }

    public static Object _md5 = (java.util.function.Function<Object, Object>) (input) ->
        __hashHex(__hashDigest("MD5", ((String) input).getBytes(java.nio.charset.StandardCharsets.UTF_8)));

    public static Object _sha256 = (java.util.function.Function<Object, Object>) (input) ->
        __hashHex(__hashDigest("SHA-256", ((String) input).getBytes(java.nio.charset.StandardCharsets.UTF_8)));

    public static Object hmacSha256 = (java.util.function.Function<Object, Object>) (secret) ->
        (java.util.function.Function<Object, Object>) (message) -> {
            try {
                javax.crypto.Mac mac = javax.crypto.Mac.getInstance("HmacSHA256");
                mac.init(new javax.crypto.spec.SecretKeySpec(
                    ((String) secret).getBytes(java.nio.charset.StandardCharsets.UTF_8), "HmacSHA256"));
                return __hashHex(mac.doFinal(((String) message).getBytes(java.nio.charset.StandardCharsets.UTF_8)));
            } catch (java.security.GeneralSecurityException failure) {
                throw new RuntimeException(failure);
            }
        };

    private static final long __xxhP1 = 0x9E3779B185EBCA87L;
    private static final long __xxhP2 = 0xC2B2AE3D27D4EB4FL;
    private static final long __xxhP3 = 0x165667B19E3779F9L;
    private static final long __xxhP4 = 0x85EBCA77C2B2AE63L;
    private static final long __xxhP5 = 0x27D4EB2F165667C5L;

    private static long __xxhRotl(long value, int shift) {
        return (value << shift) | (value >>> (64 - shift));
    }

    private static long __xxhReadLong(byte[] input, int index) {
        return (input[index] & 0xFFL)
            | ((input[index + 1] & 0xFFL) << 8)
            | ((input[index + 2] & 0xFFL) << 16)
            | ((input[index + 3] & 0xFFL) << 24)
            | ((input[index + 4] & 0xFFL) << 32)
            | ((input[index + 5] & 0xFFL) << 40)
            | ((input[index + 6] & 0xFFL) << 48)
            | ((input[index + 7] & 0xFFL) << 56);
    }

    private static int __xxhReadInt(byte[] input, int index) {
        return (input[index] & 0xFF)
            | ((input[index + 1] & 0xFF) << 8)
            | ((input[index + 2] & 0xFF) << 16)
            | ((input[index + 3] & 0xFF) << 24);
    }

    private static long __xxhRound(long accumulator, long input) {
        accumulator += input * __xxhP2;
        accumulator = __xxhRotl(accumulator, 31);
        accumulator *= __xxhP1;
        return accumulator;
    }

    private static long __xxhMergeRound(long accumulator, long value) {
        value = __xxhRound(0L, value);
        accumulator ^= value;
        accumulator = accumulator * __xxhP1 + __xxhP4;
        return accumulator;
    }

    private static long __xxh64(byte[] input) {
        int length = input.length;
        int index = 0;
        long hash;
        if (length >= 32) {
            long v1 = __xxhP1 + __xxhP2;
            long v2 = __xxhP2;
            long v3 = 0L;
            long v4 = -__xxhP1;
            while (index + 32 <= length) {
                v1 = __xxhRound(v1, __xxhReadLong(input, index)); index += 8;
                v2 = __xxhRound(v2, __xxhReadLong(input, index)); index += 8;
                v3 = __xxhRound(v3, __xxhReadLong(input, index)); index += 8;
                v4 = __xxhRound(v4, __xxhReadLong(input, index)); index += 8;
            }
            hash = __xxhRotl(v1, 1) + __xxhRotl(v2, 7) + __xxhRotl(v3, 12) + __xxhRotl(v4, 18);
            hash = __xxhMergeRound(hash, v1);
            hash = __xxhMergeRound(hash, v2);
            hash = __xxhMergeRound(hash, v3);
            hash = __xxhMergeRound(hash, v4);
        } else {
            hash = __xxhP5;
        }
        hash += length;
        while (index + 8 <= length) {
            long k1 = __xxhRound(0L, __xxhReadLong(input, index));
            hash ^= k1;
            hash = __xxhRotl(hash, 27) * __xxhP1 + __xxhP4;
            index += 8;
        }
        if (index + 4 <= length) {
            hash ^= ((long) __xxhReadInt(input, index)) * __xxhP1;
            hash = __xxhRotl(hash, 23) * __xxhP2 + __xxhP3;
            index += 4;
        }
        while (index < length) {
            hash ^= (input[index] & 0xFFL) * __xxhP5;
            hash = __xxhRotl(hash, 11) * __xxhP1;
            index++;
        }
        hash ^= hash >>> 33;
        hash *= __xxhP2;
        hash ^= hash >>> 29;
        hash *= __xxhP3;
        hash ^= hash >>> 32;
        return hash;
    }

    @SuppressWarnings("unchecked")
    public static Object _xxhash64 = (java.util.function.Function<Object, Object>) (input) ->
        (java.util.function.Function<Object, Object>) (onError) ->
        (java.util.function.Function<Object, Object>) (onSuccess) ->
        (java.util.function.Supplier<Object>) () -> {
            String result = Long.toHexString(__xxh64(((String) input).getBytes(java.nio.charset.StandardCharsets.UTF_8)));
            ((java.util.function.Supplier<Object>) ((java.util.function.Function<Object, Object>) onSuccess).apply(result)).get();
            return (java.util.function.Function<Object, Object>) (reason) ->
                (java.util.function.Function<Object, Object>) (onCancelerError) ->
                (java.util.function.Function<Object, Object>) (onCancelerSuccess) ->
                (java.util.function.Supplier<Object>) () ->
                    ((java.util.function.Supplier<Object>) ((java.util.function.Function<Object, Object>) onCancelerSuccess).apply(null)).get();
        };
