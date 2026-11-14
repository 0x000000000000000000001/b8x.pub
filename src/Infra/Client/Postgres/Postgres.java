    // Port of Postgres.js over JDBC. A handle is either a connection pool
    // (createConnectionPoolHandle) or a dedicated connection (_dedicate);
    // queries borrow from the pool and give the connection back immediately,
    // dedicated handles keep their connection until _release.
    // Java's EffectFn representation is curried and keeps the terminal Supplier.
    private static Object __pgAttempt(java.util.function.Supplier<Object> action) {
        return (java.util.function.Function<Object, Object>) onError ->
            (java.util.function.Function<Object, Object>) onSuccess ->
            (java.util.function.Supplier<Object>) () -> {
                Object result;
                try {
                    result = action.get();
                } catch (Throwable failure) {
                    Object message = failure.getMessage() == null ? failure.toString() : failure.getMessage();
                    ((java.util.function.Supplier<?>) ((java.util.function.Function<Object, Object>) onError).apply(message)).get();
                    return __pgNonCanceler();
                }
                ((java.util.function.Supplier<?>) ((java.util.function.Function<Object, Object>) onSuccess).apply(result)).get();
                return __pgNonCanceler();
            };
    }

    private static Object __pgNonCanceler() {
        return (java.util.function.Function<Object, Object>) reason ->
            (java.util.function.Function<Object, Object>) onError ->
            (java.util.function.Function<Object, Object>) onSuccess ->
            (java.util.function.Supplier<Object>) () ->
                ((java.util.function.Supplier<?>) ((java.util.function.Function<Object, Object>) onSuccess).apply(null)).get();
    }

    public static final class __PgPool {
        final String url;
        final java.util.Properties properties = new java.util.Properties();
        final java.util.concurrent.ConcurrentLinkedQueue<java.sql.Connection> idle =
            new java.util.concurrent.ConcurrentLinkedQueue<>();
        volatile boolean closed;

        __PgPool(String host, int port, String database, String user, String password) {
            this.url = "jdbc:postgresql://" + host + ":" + port + "/" + database;
            this.properties.setProperty("user", user);
            this.properties.setProperty("password", password);
        }

        java.sql.Connection borrow(boolean dedicated) throws java.sql.SQLException {
            java.sql.Connection connection = idle.poll();
            while (connection != null) {
                if (!connection.isClosed()) return prepare(connection, dedicated);
                connection = idle.poll();
            }
            return prepare(java.sql.DriverManager.getConnection(url, properties), dedicated);
        }

        private java.sql.Connection prepare(java.sql.Connection connection, boolean dedicated) throws java.sql.SQLException {
            connection.setAutoCommit(!dedicated);
            return connection;
        }

        void giveBack(java.sql.Connection connection) {
            try {
                if (!connection.getAutoCommit()) {
                    connection.rollback();
                    connection.setAutoCommit(true);
                }
            } catch (java.sql.SQLException ignored) {
            }
            if (closed) {
                try { connection.close(); } catch (java.sql.SQLException ignored) { }
            } else {
                idle.add(connection);
            }
        }

        void closeAll() {
            closed = true;
            java.sql.Connection connection;
            while ((connection = idle.poll()) != null) {
                try { connection.close(); } catch (java.sql.SQLException ignored) { }
            }
        }
    }

    public static final class __PgConnection {
        final __PgPool pool;
        final java.sql.Connection connection;

        __PgConnection(__PgPool pool, java.sql.Connection connection) {
            this.pool = pool;
            this.connection = connection;
        }
    }

    private static Object[] __pgRows(java.sql.ResultSet resultSet) throws java.sql.SQLException {
        java.sql.ResultSetMetaData meta = resultSet.getMetaData();
        int columns = meta.getColumnCount();
        java.util.List<Object> rows = new java.util.ArrayList<>();
        while (resultSet.next()) {
            java.util.Map<String, Object> row = new java.util.LinkedHashMap<>();
            for (int index = 1; index <= columns; index++) {
                row.put(meta.getColumnLabel(index), __pgValue(resultSet.getObject(index)));
            }
            rows.add(row);
        }
        return rows.toArray();
    }

    private static Object __pgValue(Object value) {
        if (value == null) return null;
        if (value instanceof Boolean || value instanceof String) return value;
        if (value instanceof Number) return ((Number) value).doubleValue();
        if (value instanceof byte[]) return new String((byte[]) value, java.nio.charset.StandardCharsets.UTF_8);
        if (value instanceof java.util.UUID) return value.toString();
        if (value instanceof java.sql.Timestamp) return ((java.sql.Timestamp) value).toInstant().toString();
        if (value instanceof java.sql.Date || value instanceof java.sql.Time) return value.toString();
        if (value instanceof org.postgresql.util.PGobject) {
            org.postgresql.util.PGobject object = (org.postgresql.util.PGobject) value;
            String type = object.getType();
            String text = object.getValue();
            if ("json".equals(type) || "jsonb".equals(type)) return __pgParseJson(text);
            return text;
        }
        if (value instanceof Object[] || value instanceof java.util.Map) return value;
        if (value instanceof java.sql.Array) {
            try {
                return ((java.sql.Array) value).getArray();
            } catch (java.sql.SQLException ignored) {
                return value.toString();
            }
        }
        return value.toString();
    }

    private static Object __pgParam(java.sql.Connection connection, Object value) {
        if (value == null) return null;
        if (value instanceof Boolean || value instanceof String) return value;
        if (value instanceof Number) {
            double number = ((Number) value).doubleValue();
            if (number == Math.rint(number) && Math.abs(number) < 9.0e15) return (long) number;
            return number;
        }
        if (value instanceof Object[] || value instanceof java.util.List) {
            Object[] items = value instanceof Object[] ? (Object[]) value : ((java.util.List<?>) value).toArray();
            Object[] elements = new Object[items.length];
            boolean jsonb = false;
            for (int index = 0; index < items.length; index++) {
                Object item = items[index];
                if (item == null || item instanceof String || item instanceof Number || item instanceof Boolean) {
                    elements[index] = item == null ? null : String.valueOf(item);
                } else {
                    jsonb = true;
                    elements[index] = __pgJsonWrite(item);
                }
            }
            try {
                return connection.createArrayOf(jsonb ? "jsonb" : "text", elements);
            } catch (java.sql.SQLException failure) {
                throw new RuntimeException(failure);
            }
        }
        if (value instanceof java.util.Map) return __pgJsonWrite(value);
        return value;
    }

    private static final class __PgJson {
        private final String input;
        private int index;

        __PgJson(String input) { this.input = input; }

        Object parse() {
            skip();
            Object value = value();
            skip();
            if (index != input.length()) throw new IllegalArgumentException("Unexpected JSON characters");
            return value;
        }

        private void skip() {
            while (index < input.length()) {
                char current = input.charAt(index);
                if (current == ' ' || current == '\t' || current == '\n' || current == '\r') index++;
                else break;
            }
        }

        private char peek() {
            if (index >= input.length()) throw new IllegalArgumentException("Unexpected end of JSON");
            return input.charAt(index);
        }

        private Object value() {
            switch (peek()) {
                case 'n': expect("null"); return null;
                case 't': expect("true"); return Boolean.TRUE;
                case 'f': expect("false"); return Boolean.FALSE;
                case '"': return string();
                case '[': return array();
                case '{': return object();
                default: return number();
            }
        }

        private void expect(String word) {
            if (!input.startsWith(word, index)) throw new IllegalArgumentException("Invalid JSON literal");
            index += word.length();
        }

        private String string() {
            index++;
            StringBuilder out = new StringBuilder();
            while (true) {
                if (index >= input.length()) throw new IllegalArgumentException("Unterminated JSON string");
                char current = input.charAt(index++);
                if (current == '"') return out.toString();
                if (current != '\\') { out.append(current); continue; }
                char escape = input.charAt(index++);
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
                        out.append((char) Integer.parseInt(input.substring(index, index + 4), 16));
                        index += 4;
                        break;
                    default: throw new IllegalArgumentException("Invalid JSON escape");
                }
            }
        }

        private Object number() {
            int start = index;
            if (peek() == '-') index++;
            while (index < input.length() && Character.isDigit(input.charAt(index))) index++;
            if (index < input.length() && input.charAt(index) == '.') {
                index++;
                while (index < input.length() && Character.isDigit(input.charAt(index))) index++;
            }
            if (index < input.length() && (input.charAt(index) == 'e' || input.charAt(index) == 'E')) {
                index++;
                if (index < input.length() && (input.charAt(index) == '+' || input.charAt(index) == '-')) index++;
                while (index < input.length() && Character.isDigit(input.charAt(index))) index++;
            }
            return Double.parseDouble(input.substring(start, index));
        }

        private Object array() {
            index++;
            java.util.List<Object> items = new java.util.ArrayList<>();
            skip();
            if (peek() == ']') { index++; return items.toArray(); }
            while (true) {
                skip();
                items.add(value());
                skip();
                char current = peek();
                if (current == ',') { index++; continue; }
                if (current == ']') { index++; return items.toArray(); }
                throw new IllegalArgumentException("Expected ',' or ']'");
            }
        }

        private Object object() {
            index++;
            java.util.Map<String, Object> fields = new java.util.LinkedHashMap<>();
            skip();
            if (peek() == '}') { index++; return fields; }
            while (true) {
                skip();
                String key = string();
                skip();
                if (peek() != ':') throw new IllegalArgumentException("Expected ':'");
                index++;
                skip();
                fields.put(key, value());
                skip();
                char current = peek();
                if (current == ',') { index++; continue; }
                if (current == '}') { index++; return fields; }
                throw new IllegalArgumentException("Expected ',' or '}'");
            }
        }
    }

    private static Object __pgParseJson(String text) {
        return new __PgJson(text).parse();
    }

    private static String __pgJsonWrite(Object value) {
        StringBuilder out = new StringBuilder();
        __pgJsonWrite(out, value);
        return out.toString();
    }

    private static void __pgJsonWrite(StringBuilder out, Object value) {
        if (value == null) { out.append("null"); return; }
        if (value instanceof Boolean || value instanceof Number) { out.append(value.toString()); return; }
        if (value instanceof String) {
            out.append('"').append(((String) value).replace("\\", "\\\\").replace("\"", "\\\"")).append('"');
            return;
        }
        if (value instanceof Object[] || value instanceof java.util.List) {
            Object[] items = value instanceof Object[] ? (Object[]) value : ((java.util.List<?>) value).toArray();
            out.append('[');
            for (int index = 0; index < items.length; index++) {
                if (index > 0) out.append(',');
                __pgJsonWrite(out, items[index]);
            }
            out.append(']');
            return;
        }
        if (value instanceof java.util.Map) {
            out.append('{');
            boolean first = true;
            for (java.util.Map.Entry<?, ?> entry : ((java.util.Map<?, ?>) value).entrySet()) {
                if (!first) out.append(',');
                first = false;
                __pgJsonWrite(out, String.valueOf(entry.getKey()));
                out.append(':');
                __pgJsonWrite(out, entry.getValue());
            }
            out.append('}');
            return;
        }
        out.append('"').append(String.valueOf(value).replace("\"", "\\\"")).append('"');
    }

    private static Object __pgQuery(Object handle, String sql, Object[] params, boolean countOnly) {
        if (handle instanceof __PgPool) {
            __PgPool pool = (__PgPool) handle;
            try {
                java.sql.Connection connection = pool.borrow(false);
                try {
                    return __pgRun(connection, sql, params, countOnly);
                } finally {
                    pool.giveBack(connection);
                }
            } catch (java.sql.SQLException failure) {
                throw new RuntimeException(failure);
            }
        }
        __PgConnection connection = (__PgConnection) handle;
        try {
            return __pgRun(connection.connection, sql, params, countOnly);
        } catch (java.sql.SQLException failure) {
            throw new RuntimeException(failure);
        }
    }

    // | The b8x queries use PostgreSQL `$n` placeholders; pgjdbc only
    // | understands `?`. Rewrite the statement and remember, for every `?`,
    // | which parameter value it stands for.
    private static final class __PgStatement {
        final String sql;
        final int[] parameterOrder;
        __PgStatement(String sql, int[] parameterOrder) { this.sql = sql; this.parameterOrder = parameterOrder; }
    }

    private static __PgStatement __pgRewrite(String sql) {
        StringBuilder out = new StringBuilder();
        java.util.List<Integer> order = new java.util.ArrayList<>();
        boolean single = false, quoted = false, lineComment = false, blockComment = false;
        for (int index = 0; index < sql.length(); index++) {
            char current = sql.charAt(index);
            if (lineComment) {
                out.append(current);
                if (current == '\n') lineComment = false;
                continue;
            }
            if (blockComment) {
                out.append(current);
                if (current == '*' && index + 1 < sql.length() && sql.charAt(index + 1) == '/') {
                    out.append('/');
                    index++;
                    blockComment = false;
                }
                continue;
            }
            if (single) {
                out.append(current);
                if (current == '\'') {
                    if (index + 1 < sql.length() && sql.charAt(index + 1) == '\'') { out.append('\''); index++; }
                    else single = false;
                }
                continue;
            }
            if (quoted) {
                out.append(current);
                if (current == '"') {
                    if (index + 1 < sql.length() && sql.charAt(index + 1) == '"') { out.append('"'); index++; }
                    else quoted = false;
                }
                continue;
            }
            if (current == '-' && index + 1 < sql.length() && sql.charAt(index + 1) == '-') {
                out.append("--");
                index++;
                lineComment = true;
                continue;
            }
            if (current == '/' && index + 1 < sql.length() && sql.charAt(index + 1) == '*') {
                out.append("/*");
                index++;
                blockComment = true;
                continue;
            }
            if (current == '\'') { single = true; out.append(current); continue; }
            if (current == '"') { quoted = true; out.append(current); continue; }
            if (current == '$' && index + 1 < sql.length() && Character.isDigit(sql.charAt(index + 1))) {
                int cursor = index + 1;
                int value = 0;
                while (cursor < sql.length() && Character.isDigit(sql.charAt(cursor))) {
                    value = value * 10 + (sql.charAt(cursor) - '0');
                    cursor++;
                }
                out.append('?');
                order.add(value);
                index = cursor - 1;
                continue;
            }
            if (current == '?') {
                // Literal question marks come from operators such as `@?`;
                // pgjdbc reads `??` as an escaped question mark.
                out.append("??");
                continue;
            }
            out.append(current);
        }
        int[] parameterOrder = new int[order.size()];
        for (int index = 0; index < parameterOrder.length; index++) parameterOrder[index] = order.get(index);
        return new __PgStatement(out.toString(), parameterOrder);
    }

    private static Object __pgRun(java.sql.Connection connection, String sql, Object[] params, boolean countOnly) throws java.sql.SQLException {
        __PgStatement rewritten = __pgRewrite(sql);
        java.sql.PreparedStatement statement = connection.prepareStatement(rewritten.sql);
        try {
            for (int index = 0; index < rewritten.parameterOrder.length; index++) {
                int source = rewritten.parameterOrder[index];
                Object value = source >= 1 && source <= params.length ? params[source - 1] : null;
                if (value instanceof String) {
                    // The `pg` driver sends scalars untyped so the server infers
                    // the parameter type from context (bigint >= $1, text = $1);
                    // pgjdbc would otherwise declare varchar/bigint and fail.
                    statement.setObject(index + 1, value, java.sql.Types.OTHER);
                } else if (value instanceof Boolean || value instanceof Number) {
                    statement.setObject(index + 1, String.valueOf(__pgParam(connection, value)), java.sql.Types.OTHER);
                } else if (value instanceof java.util.Map) {
                    statement.setObject(index + 1, __pgJsonWrite(value), java.sql.Types.OTHER);
                } else {
                    statement.setObject(index + 1, __pgParam(connection, value));
                }
            }
            boolean hasRows = statement.execute();
            if (countOnly) {
                if (hasRows) {
                    java.sql.ResultSet resultSet = statement.getResultSet();
                    long rows = 0;
                    while (resultSet.next()) rows++;
                    return (double) rows;
                }
                long updated = statement.getUpdateCount();
                return (double) updated;
            }
            if (hasRows) return __pgRows(statement.getResultSet());
            return new Object[0];
        } finally {
            statement.close();
        }
    }

    public static Object _createConnectionPoolHandle = (java.util.function.Function<Object, Object>) (host) ->
        (java.util.function.Function<Object, Object>) (port) ->
        (java.util.function.Function<Object, Object>) (database) ->
        (java.util.function.Function<Object, Object>) (user) ->
        (java.util.function.Function<Object, Object>) (password) ->
        (java.util.function.Function<Object, Object>) (idleTimeoutMs) ->
        (java.util.function.Supplier<Object>) () ->
            new __PgPool((String) host, ((Number) port).intValue(), (String) database, (String) user, (String) password);

    public static Object _closeHandle = (java.util.function.Function<Object, Object>) (handle) ->
        __pgAttempt(() -> {
            if (handle instanceof __PgPool) ((__PgPool) handle).closeAll();
            else if (handle instanceof __PgConnection) {
                try { ((__PgConnection) handle).connection.close(); } catch (java.sql.SQLException ignored) { }
            }
            return null;
        });

    public static Object _query = (java.util.function.Function<Object, Object>) (encodeJson) ->
        (java.util.function.Function<Object, Object>) (handle) ->
        (java.util.function.Function<Object, Object>) (sql) ->
        (java.util.function.Function<Object, Object>) (params) ->
        __pgAttempt(() -> __pgQuery(handle, (String) sql, (Object[]) params, false));

    public static Object _queryCount = (java.util.function.Function<Object, Object>) (encodeJson) ->
        (java.util.function.Function<Object, Object>) (handle) ->
        (java.util.function.Function<Object, Object>) (sql) ->
        (java.util.function.Function<Object, Object>) (params) ->
        __pgAttempt(() -> __pgQuery(handle, (String) sql, (Object[]) params, true));

    public static Object _escapeIdentifier = (java.util.function.Function<Object, Object>) (identifier) ->
        "\"" + ((String) identifier).replace("\"", "\"\"") + "\"";

    public static Object _dedicate = (java.util.function.Function<Object, Object>) (handle) ->
        __pgAttempt(() -> {
            __PgPool pool = (__PgPool) handle;
            try {
                return new __PgConnection(pool, pool.borrow(true));
            } catch (java.sql.SQLException failure) {
                throw new RuntimeException(failure);
            }
        });

    public static Object _release = (java.util.function.Function<Object, Object>) (handle) ->
        __pgAttempt(() -> {
            __PgConnection connection = (__PgConnection) handle;
            connection.pool.giveBack(connection.connection);
            return null;
        });
