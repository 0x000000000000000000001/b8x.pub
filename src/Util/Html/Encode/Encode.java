    // Port of Encode.js over jsoup: full HTML5 entity decoding, and the same
    // encoding set as `he` (unsafe symbols plus non-ASCII as hex references).
    public static Object _decodeHtmlEntities = (java.util.function.Function<Object, Object>) (input) ->
        org.jsoup.parser.Parser.unescapeEntities((String) input, false);

    public static Object _encodeHtmlEntities = (java.util.function.Function<Object, Object>) (input) -> {
        String value = (String) input;
        StringBuilder out = new StringBuilder();
        for (int index = 0; index < value.length(); ) {
            int codePoint = value.codePointAt(index);
            index += Character.charCount(codePoint);
            switch (codePoint) {
                case '&': out.append("&#x26;"); break;
                case '<': out.append("&#x3C;"); break;
                case '>': out.append("&#x3E;"); break;
                case '"': out.append("&#x22;"); break;
                case '\'': out.append("&#x27;"); break;
                default:
                    if (codePoint >= 128) {
                        out.append("&#x").append(Integer.toHexString(codePoint).toUpperCase()).append(';');
                    } else {
                        out.appendCodePoint(codePoint);
                    }
            }
        }
        return out.toString();
    };
