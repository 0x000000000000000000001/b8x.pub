    // Builders map tags to handlers; PureScript supplies the selected payload.
    public static Object empty = new java.util.LinkedHashMap<String, Object>();

    public static Object _on = (java.util.function.Function<Object, Object>) (tag) ->
        (java.util.function.Function<Object, Object>) (handler) ->
        (java.util.function.Function<Object, Object>) (builders) -> {
            java.util.Map<String, Object> copy = new java.util.LinkedHashMap<>((java.util.Map<String, Object>) builders);
            copy.put((String) tag, handler);
            return copy;
        };

    public static Object _build = (java.util.function.Function<Object, Object>) (builders) ->
        (java.util.function.Function<Object, Object>) (fallback) ->
        (java.util.function.Function<Object, Object>) (tag) ->
        (java.util.function.Function<Object, Object>) (payload) ->
        (java.util.function.Function<Object, Object>) (original) -> {
            java.util.Map<String, Object> handlers = (java.util.Map<String, Object>) builders;
            Object handler = handlers.get((String) tag);
            if (handler != null) return ((java.util.function.Function<Object, Object>) handler).apply(payload);
            return ((java.util.function.Function<Object, Object>) fallback).apply(original);
        };
