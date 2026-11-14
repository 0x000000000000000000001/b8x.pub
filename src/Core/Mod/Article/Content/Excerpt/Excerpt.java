    // Port of Excerpt.js over jsoup: truncate the visible text in document
    // order, then return the healed body HTML.
    private static void __excerptWalk(org.jsoup.nodes.Node node, int[] remaining, boolean[] truncated) {
        if (truncated[0]) {
            node.remove();
            return;
        }
        if (node instanceof org.jsoup.nodes.TextNode) {
            String text = ((org.jsoup.nodes.TextNode) node).getWholeText();
            if (text.length() > remaining[0]) {
                int space = text.indexOf(' ', remaining[0]);
                if (space != -1) ((org.jsoup.nodes.TextNode) node).text(text.substring(0, space));
                remaining[0] = 0;
                truncated[0] = true;
            } else {
                remaining[0] -= text.length();
            }
            return;
        }
        for (org.jsoup.nodes.Node child : new java.util.ArrayList<>(node.childNodes())) {
            __excerptWalk(child, remaining, truncated);
        }
    }

    public static Object _truncateInnerTextThenHealOuterHtml = (java.util.function.Function<Object, Object>) (limit) ->
        (java.util.function.Function<Object, Object>) (suffix) ->
        (java.util.function.Function<Object, Object>) (htmlStr) -> {
            int limitValue = ((Number) limit).intValue();
            String html = (String) htmlStr;
            if (limitValue < 0 || html == null || html.trim().isEmpty()) return html;
            org.jsoup.nodes.Document document = org.jsoup.Jsoup.parseBodyFragment(html);
            org.jsoup.nodes.Element body = document.body();
            int[] remaining = { limitValue };
            boolean[] truncated = { false };
            for (org.jsoup.nodes.Node child : new java.util.ArrayList<>(body.childNodes())) {
                __excerptWalk(child, remaining, truncated);
            }
            return body.html() + (truncated[0] ? (String) suffix : "");
        };
