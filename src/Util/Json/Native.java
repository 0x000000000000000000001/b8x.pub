    // Port of Util/Json/Native.js: parse a JSON text into this backend's
    // representation (null, Boolean, Double, String, Object[], LinkedHashMap).
    public static Object parseJSONImpl = (java.util.function.Function<Object, Object>) (left) ->
        (java.util.function.Function<Object, Object>) (right) ->
        (java.util.function.Function<Object, Object>) (input) -> {
            try {
                return ((java.util.function.Function<Object, Object>) right).apply(__jsonParse((String) input));
            } catch (Throwable failure) {
                return ((java.util.function.Function<Object, Object>) left)
                    .apply(failure.getMessage() == null ? failure.toString() : failure.getMessage());
            }
        };

    private static Object __jsonParse(String input) {
        int[] index = { 0 };
        Object value = __jsonValue(input, index);
        __jsonSkip(input, index);
        if (index[0] != input.length()) throw new IllegalArgumentException("Unexpected JSON characters");
        return value;
    }

    private static void __jsonSkip(String input, int[] index) {
        while (index[0] < input.length()) {
            char current = input.charAt(index[0]);
            if (current == ' ' || current == '\t' || current == '\n' || current == '\r') index[0]++;
            else break;
        }
    }

    private static char __jsonPeek(String input, int[] index) {
        if (index[0] >= input.length()) throw new IllegalArgumentException("Unexpected end of JSON input");
        return input.charAt(index[0]);
    }

    private static Object __jsonValue(String input, int[] index) {
        __jsonSkip(input, index);
        switch (__jsonPeek(input, index)) {
            case 'n': __jsonWord(input, index, "null"); return null;
            case 't': __jsonWord(input, index, "true"); return Boolean.TRUE;
            case 'f': __jsonWord(input, index, "false"); return Boolean.FALSE;
            case '"': return __jsonString(input, index);
            case '[': return __jsonArray(input, index);
            case '{': return __jsonObject(input, index);
            default: return __jsonNumber(input, index);
        }
    }

    private static void __jsonWord(String input, int[] index, String word) {
        if (!input.startsWith(word, index[0])) throw new IllegalArgumentException("Invalid JSON literal");
        index[0] += word.length();
    }

    private static String __jsonString(String input, int[] index) {
        index[0]++;
        StringBuilder out = new StringBuilder();
        while (true) {
            if (index[0] >= input.length()) throw new IllegalArgumentException("Unterminated JSON string");
            char current = input.charAt(index[0]++);
            if (current == '"') return out.toString();
            if (current != '\\') { out.append(current); continue; }
            char escape = input.charAt(index[0]++);
            switch (escape) {
                case '"': out.append('"'); break;
                case '\\': out.append('\\'); break;
                case '/': out.append('/'); break;
                case 'b': out.append('\b'); break;
                case 'f': out.append('\f'); break;
                case 'n': out.append('\n'); break;
                case 'r': out.append('\r'); break;
                case 't': out.append('\t'); break;
                case 'u':
                    out.append((char) Integer.parseInt(input.substring(index[0], index[0] + 4), 16));
                    index[0] += 4;
                    break;
                default: throw new IllegalArgumentException("Invalid JSON escape");
            }
        }
    }

    private static Object __jsonNumber(String input, int[] index) {
        int start = index[0];
        if (__jsonPeek(input, index) == '-') index[0]++;
        while (index[0] < input.length() && Character.isDigit(input.charAt(index[0]))) index[0]++;
        if (index[0] < input.length() && input.charAt(index[0]) == '.') {
            index[0]++;
            while (index[0] < input.length() && Character.isDigit(input.charAt(index[0]))) index[0]++;
        }
        if (index[0] < input.length() && (input.charAt(index[0]) == 'e' || input.charAt(index[0]) == 'E')) {
            index[0]++;
            if (index[0] < input.length() && (input.charAt(index[0]) == '+' || input.charAt(index[0]) == '-')) index[0]++;
            while (index[0] < input.length() && Character.isDigit(input.charAt(index[0]))) index[0]++;
        }
        if (index[0] == start) throw new IllegalArgumentException("Invalid JSON value");
        return Double.parseDouble(input.substring(start, index[0]));
    }

    private static Object __jsonArray(String input, int[] index) {
        index[0]++;
        java.util.List<Object> items = new java.util.ArrayList<>();
        __jsonSkip(input, index);
        if (__jsonPeek(input, index) == ']') { index[0]++; return items.toArray(); }
        while (true) {
            items.add(__jsonValue(input, index));
            __jsonSkip(input, index);
            char current = __jsonPeek(input, index);
            if (current == ',') { index[0]++; continue; }
            if (current == ']') { index[0]++; return items.toArray(); }
            throw new IllegalArgumentException("Expected ',' or ']'");
        }
    }

    private static Object __jsonObject(String input, int[] index) {
        index[0]++;
        java.util.Map<String, Object> fields = new java.util.LinkedHashMap<>();
        __jsonSkip(input, index);
        if (__jsonPeek(input, index) == '}') { index[0]++; return fields; }
        while (true) {
            __jsonSkip(input, index);
            String key = __jsonString(input, index);
            __jsonSkip(input, index);
            if (__jsonPeek(input, index) != ':') throw new IllegalArgumentException("Expected ':'");
            index[0]++;
            fields.put(key, __jsonValue(input, index));
            __jsonSkip(input, index);
            char current = __jsonPeek(input, index);
            if (current == ',') { index[0]++; continue; }
            if (current == '}') { index[0]++; return fields; }
            throw new IllegalArgumentException("Expected ',' or '}'");
        }
    }
