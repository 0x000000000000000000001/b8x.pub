    // Port of Ulid.js. Crockford base32: 48 bits of time plus 80 random bits.
    private static final String __ulidAlphabet = "0123456789ABCDEFGHJKMNPQRSTVWXYZ";

    private static String __ulidGenerate() {
        long time = System.currentTimeMillis();
        char[] out = new char[26];
        for (int index = 9; index >= 0; index--) {
            out[index] = __ulidAlphabet.charAt((int) (time & 31));
            time >>>= 5;
        }
        java.util.concurrent.ThreadLocalRandom random = java.util.concurrent.ThreadLocalRandom.current();
        for (int index = 10; index < 26; index++) {
            out[index] = __ulidAlphabet.charAt(random.nextInt(32));
        }
        return new String(out);
    }

    public static Object _generateUlid = (java.util.function.Supplier<Object>) () ->
        __ulidGenerate().toLowerCase(java.util.Locale.ROOT);

    public static Object _isValid = (java.util.function.Function<Object, Object>) (input) -> {
        String value = (String) input;
        if (value.length() != 26) return false;
        if (__ulidAlphabet.indexOf(Character.toUpperCase(value.charAt(0))) < 0
            || __ulidAlphabet.indexOf(Character.toUpperCase(value.charAt(0))) > 7) return false;
        for (int index = 1; index < value.length(); index++) {
            if (__ulidAlphabet.indexOf(Character.toUpperCase(value.charAt(index))) < 0) return false;
        }
        return true;
    };
