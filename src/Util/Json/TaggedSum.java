    // Port of TaggedSum.js: a tagged value without a `value` field gets one
    // with null (the backend has no `undefined`), so the generic decoder sees
    // the field.
    public static Object fixTaggedSumRepMissingValue = (java.util.function.Function<Object, Object>) (value) -> {
        if (value instanceof java.util.Map) {
            java.util.Map<String, Object> fields = (java.util.Map<String, Object>) value;
            if (fields.get("type") instanceof String && !fields.containsKey("value")) {
                java.util.Map<String, Object> copy = new java.util.LinkedHashMap<>(fields);
                copy.put("value", null);
                return copy;
            }
        }
        return value;
    };
