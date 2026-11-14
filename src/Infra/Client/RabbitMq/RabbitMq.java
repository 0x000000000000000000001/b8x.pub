    private interface RabbitWork {
        void run(java.util.function.Function<Object, Object> onSuccess, java.util.function.Function<Object, Object> onError);
    }

    private static void __rabbitSettle(Object callback, Object value) {
        ((java.util.function.Supplier<Object>) ((java.util.function.Function<Object, Object>) callback).apply(value)).get();
    }

    private static Object __rabbitAff(RabbitWork work) {
        return (java.util.function.Function<Object, Object>) onError ->
            (java.util.function.Function<Object, Object>) onSuccess ->
            (java.util.function.Supplier<Object>) () -> {
                work.run((java.util.function.Function<Object, Object>) onSuccess, (java.util.function.Function<Object, Object>) onError);
                // The underlying SDK operation is not cancellable through this bridge.
                return (java.util.function.Function<Object, Object>) cancelError ->
                    (java.util.function.Function<Object, Object>) onCancelError ->
                    (java.util.function.Function<Object, Object>) onCancelSuccess ->
                    (java.util.function.Supplier<Object>) () -> {
                        __rabbitSettle(onCancelSuccess, null);
                        return null;
                    };
            };
    }

    public static Object _createConnectionImpl = (java.util.function.Function<Object, Object>) (host) ->
        (java.util.function.Function<Object, Object>) (port) ->
        (java.util.function.Function<Object, Object>) (user) ->
        (java.util.function.Function<Object, Object>) (password) ->
        __rabbitAff((resolve, reject) -> {
            try {
                com.rabbitmq.client.ConnectionFactory factory = new com.rabbitmq.client.ConnectionFactory();
                factory.setHost((String) host);
                factory.setPort(((Number) port).intValue());
                factory.setUsername((String) user);
                factory.setPassword((String) password);
                factory.setVirtualHost("/");
                factory.setRequestedHeartbeat(60);
                __rabbitSettle(resolve, factory.newConnection());
            } catch (Throwable failure) {
                __rabbitSettle(reject, failure);
            }
        });

    public static Object _createChannelImpl = (java.util.function.Function<Object, Object>) (connection) ->
        __rabbitAff((resolve, reject) -> {
            try {
                __rabbitSettle(resolve, ((com.rabbitmq.client.Connection) connection).createChannel());
            } catch (Throwable failure) {
                __rabbitSettle(reject, failure);
            }
        });

    public static Object _assertQueueImpl = (java.util.function.Function<Object, Object>) (channel) ->
        (java.util.function.Function<Object, Object>) (queue) ->
        __rabbitAff((resolve, reject) -> {
            try {
                ((com.rabbitmq.client.Channel) channel).queueDeclare((String) queue, true, false, false, null);
                __rabbitSettle(resolve, null);
            } catch (Throwable failure) {
                __rabbitSettle(reject, failure);
            }
        });

    public static Object _sendToQueueImpl = (java.util.function.Function<Object, Object>) (channel) ->
        (java.util.function.Function<Object, Object>) (queue) ->
        (java.util.function.Function<Object, Object>) (content) ->
        __rabbitAff((resolve, reject) -> {
            try {
                ((com.rabbitmq.client.Channel) channel).basicPublish(
                    "", (String) queue,
                    com.rabbitmq.client.MessageProperties.PERSISTENT_TEXT_PLAIN,
                    ((String) content).getBytes(java.nio.charset.StandardCharsets.UTF_8));
                __rabbitSettle(resolve, null);
            } catch (Throwable failure) {
                __rabbitSettle(reject, failure);
            }
        });

    public static Object _consumeImpl = (java.util.function.Function<Object, Object>) (channel) ->
        (java.util.function.Function<Object, Object>) (queue) ->
        (java.util.function.Function<Object, Object>) (onMessage) ->
        __rabbitAff((resolve, reject) -> {
            try {
                com.rabbitmq.client.Channel consumer = (com.rabbitmq.client.Channel) channel;
                consumer.basicConsume(
                    (String) queue,
                    false,
                    (consumerTag, delivery) -> {
                        try {
                            Object effect = ((java.util.function.Function<Object, Object>) onMessage)
                                .apply(new String(delivery.getBody(), java.nio.charset.StandardCharsets.UTF_8));
                            if (effect instanceof java.util.function.Supplier) {
                                ((java.util.function.Supplier<Object>) effect).get();
                            }
                            consumer.basicAck(delivery.getEnvelope().getDeliveryTag(), false);
                        } catch (Throwable ignored) {
                        }
                    },
                    consumerTag -> { });
                __rabbitSettle(resolve, null);
            } catch (Throwable failure) {
                __rabbitSettle(reject, failure);
            }
        });

    public static Object _closeConnectionImpl = (java.util.function.Function<Object, Object>) (connection) ->
        __rabbitAff((resolve, reject) -> {
            try {
                ((com.rabbitmq.client.Connection) connection).close();
                __rabbitSettle(resolve, null);
            } catch (Throwable failure) {
                __rabbitSettle(reject, failure);
            }
        });

    public static Object _closeChannelImpl = (java.util.function.Function<Object, Object>) (channel) ->
        __rabbitAff((resolve, reject) -> {
            try {
                ((com.rabbitmq.client.Channel) channel).close();
                __rabbitSettle(resolve, null);
            } catch (Throwable failure) {
                __rabbitSettle(reject, failure);
            }
        });
