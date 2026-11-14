    // Port of String.js.
    public static Object removeAccents = (java.util.function.Function<Object, Object>) (input) ->
        java.text.Normalizer.normalize((String) input, java.text.Normalizer.Form.NFD).replaceAll("\\p{M}+", "");

    public static Object upperCaseFirst = (java.util.function.Function<Object, Object>) (input) -> {
        String value = (String) input;
        return value.isEmpty() ? value : Character.toUpperCase(value.charAt(0)) + value.substring(1);
    };

    public static Object lowerCaseFirst = (java.util.function.Function<Object, Object>) (input) -> {
        String value = (String) input;
        return value.isEmpty() ? value : Character.toLowerCase(value.charAt(0)) + value.substring(1);
    };
