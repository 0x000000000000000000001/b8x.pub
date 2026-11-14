    // Port of Dom.js. Sanitization uses jsoup with a DOMPurify-like allowlist;
    // the remaining helpers touch the browser document and are inert here.
    private static final org.jsoup.safety.Safelist __domSafelist =
        org.jsoup.safety.Safelist.relaxed()
            .addTags(
                "figure", "figcaption", "section", "article", "aside", "header", "footer",
                "main", "nav", "time", "mark", "wbr", "source", "track", "video", "audio",
                "picture", "del", "ins", "kbd", "samp", "var", "dfn", "abbr", "bdi", "bdo",
                "ruby", "rt", "rp", "details", "summary", "dialog", "h1", "h2", "h3", "h4", "h5", "h6");

    public static Object _sanitize = (java.util.function.Function<Object, Object>) (dirtyHtml) ->
        org.jsoup.Jsoup.clean((String) dirtyHtml, __domSafelist);

    public static Object _setMetaContent = (java.util.function.Function<Object, Object>) (name) ->
        (java.util.function.Function<Object, Object>) (content) ->
        (java.util.function.Supplier<Object>) () -> null;

    public static Object _setMetaRobotsNoIndex = (java.util.function.Supplier<Object>) () -> null;

    public static Object _setMetaRobotsDefault = (java.util.function.Supplier<Object>) () -> null;

    public static Object _scrollTopAll = (java.util.function.Function<Object, Object>) (element) ->
        (java.util.function.Supplier<Object>) () -> null;

    public static Object _setWindowLocationHref = (java.util.function.Function<Object, Object>) (href) ->
        (java.util.function.Supplier<Object>) () -> null;

    public static Object _setBodyOverflowHidden = (java.util.function.Supplier<Object>) () -> null;

    public static Object _setBodyOverflowVisible = (java.util.function.Supplier<Object>) () -> null;
