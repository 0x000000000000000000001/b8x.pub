    // Port of Clean.js: tags outside the whitelist are removed (or replaced
    // by a space), everything else is left untouched.
    public static Object _untag = (java.util.function.Function<Object, Object>) (isWhiteAll) ->
        (java.util.function.Function<Object, Object>) (whiteTags) ->
        (java.util.function.Function<Object, Object>) (isBlackAll) ->
        (java.util.function.Function<Object, Object>) (blackTags) ->
        (java.util.function.Function<Object, Object>) (replaceWithSpace) ->
        (java.util.function.Function<Object, Object>) (input) -> {
            java.util.Set<String> whites = new java.util.HashSet<>();
            for (Object tag : (Object[]) whiteTags) whites.add(((String) tag).toLowerCase(java.util.Locale.ROOT));
            java.util.Set<String> blacks = new java.util.HashSet<>();
            for (Object tag : (Object[]) blackTags) blacks.add(((String) tag).toLowerCase(java.util.Locale.ROOT));
            java.util.regex.Matcher matcher = java.util.regex.Pattern
                .compile("</?([a-zA-Z0-9:-]+)[^>]*>")
                .matcher((String) input);
            StringBuffer out = new StringBuffer();
            while (matcher.find()) {
                String tag = matcher.group(1).toLowerCase(java.util.Locale.ROOT);
                boolean kept = ((Boolean) isWhiteAll || whites.contains(tag))
                    && !((Boolean) isBlackAll || blacks.contains(tag));
                matcher.appendReplacement(out, java.util.regex.Matcher.quoteReplacement(
                    kept ? matcher.group() : ((Boolean) replaceWithSpace ? " " : "")));
            }
            matcher.appendTail(out);
            return out.toString();
        };
