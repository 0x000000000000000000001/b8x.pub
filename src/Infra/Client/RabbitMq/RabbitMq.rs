use futures_util::StreamExt;
use lapin::{options::*, types::FieldTable, BasicProperties, ConnectionProperties};
use purust_core::Value as MqValue;
use std::sync::{Arc, Mutex};

pub struct Connection {
    pub inner: lapin::Connection,
}
pub struct Channel {
    pub inner: lapin::Channel,
    // A channel owns its connection, as in amqplib.
    _connection: Arc<Connection>,
}
type MqResult = Result<MqValue, MqValue>;
type MqCallback = MqValue;

fn mq_error(error: impl std::fmt::Display) -> MqValue {
    Purs_Effect_Exception::Effect_Exception_error(purust_core::purust_string_from_utf8(
        &error.to_string(),
    ))
}
fn mq_aff(action: impl Fn(MqValue, MqValue) + Send + Sync + 'static) -> MqValue {
    MqValue::Func2(purust_core::Func2::Shared(Arc::new(
        move |onError, onSuccess| {
            action(onError, onSuccess);
            // Existing Promise operations could not be aborted through Aff.
            MqValue::Func3(purust_core::Func3::Shared(Arc::new(
                |_, _, onCancelSuccess| onCancelSuccess.unwrap_func1()(MqValue::Unit),
            )))
        },
    )))
}
fn mq_box<T: Send + Sync + 'static>(value: T) -> MqValue {
    MqValue::Class(Arc::new(value))
}
fn mq_spawn<F, C>(onError: MqValue, onSuccess: MqValue, future: F, complete: C)
where
    F: std::future::Future<Output = MqResult> + Send + 'static,
    C: Fn(MqValue) -> MqValue + Send + Sync + 'static,
{
    Purs_Effect_Aff::purust_aff_spawn_native(future, move |result| {
        match result {
            Ok(value) => onSuccess.unwrap_func1()(complete(value)),
            Err(error) => onError.unwrap_func1()(error),
        };
    });
}

// Every receive and acknowledgement remains registered with Aff. Delivery
// callbacks run serially in the Aff microtask context, never on a Tokio worker.
// An exception in the Effect deliberately prevents acknowledgement.
fn mq_receive(mut consumer: lapin::Consumer, callback: MqCallback) {
    Purs_Effect_Aff::purust_aff_spawn_native(
        async move {
            let delivery = consumer.next().await.transpose().map_err(mq_error)?;
            Ok(mq_box(Mutex::new(Some((consumer, delivery)))))
        },
        move |result| {
            let value = match result {
                Ok(value) => value,
                Err(error) => Purs_Effect_Exception::purust_exception_raise(error),
            };
            let (consumer, delivery) = value
                .unwrap_class::<Mutex<Option<(lapin::Consumer, Option<lapin::message::Delivery>)>>>(
                )
                .lock()
                .unwrap()
                .take()
                .unwrap();
            if let Some(delivery) = delivery {
                let content =
                    purust_core::purust_string_from_utf8(&String::from_utf8_lossy(&delivery.data));
                callback.unwrap_func1()(MqValue::String(content));
                Purs_Effect_Aff::purust_aff_spawn_native(
                    async move {
                        delivery
                            .ack(BasicAckOptions::default())
                            .await
                            .map_err(mq_error)?;
                        Ok(mq_box(Mutex::new(Some(consumer))))
                    },
                    move |result| match result {
                        Ok(value) => mq_receive(
                            value
                                .unwrap_class::<Mutex<Option<lapin::Consumer>>>()
                                .lock()
                                .unwrap()
                                .take()
                                .unwrap(),
                            callback,
                        ),
                        Err(error) => Purs_Effect_Exception::purust_exception_raise(error),
                    },
                );
            }
        },
    );
}

pub fn Infra_Client_RabbitMq_RabbitMq__createConnectionImpl(
    host: String,
    port: i64,
    user: String,
    password: String,
) -> MqValue {
    mq_aff(move |onError, onSuccess| {
        let port = u16::try_from(port).map_err(|_| mq_error("Invalid RabbitMQ port"));
        let mut uri = lapin::uri::AMQPUri::default();
        uri.authority.host = purust_core::purust_string_to_utf8_lossy(&host);
        uri.authority.userinfo.username = purust_core::purust_string_to_utf8_lossy(&user);
        uri.authority.userinfo.password = purust_core::purust_string_to_utf8_lossy(&password);
        uri.vhost = "/".to_owned();
        uri.query.heartbeat = Some(60);
        uri.query.frame_max = Some(0);
        mq_spawn(
            onError,
            onSuccess,
            async move {
                uri.authority.port = port?;
                let inner = lapin::Connection::connect_uri(uri, ConnectionProperties::default())
                    .await
                    .map_err(mq_error)?;
                Ok(mq_box(Arc::new(Connection { inner })))
            },
            |value| value,
        )
    })
}
pub fn Infra_Client_RabbitMq_RabbitMq__createChannelImpl(connection: Arc<Connection>) -> MqValue {
    mq_aff(move |onError, onSuccess| {
        let connection = connection.clone();
        mq_spawn(
            onError,
            onSuccess,
            async move {
                let inner = connection.inner.create_channel().await.map_err(mq_error)?;
                Ok(mq_box(Arc::new(Channel {
                    inner,
                    _connection: connection,
                })))
            },
            |value| value,
        )
    })
}
pub fn Infra_Client_RabbitMq_RabbitMq__assertQueueImpl(
    channel: Arc<Channel>,
    queue: String,
) -> MqValue {
    mq_aff(move |onError, onSuccess| {
        let channel = channel.clone();
        let queue = purust_core::purust_string_to_utf8_lossy(&queue);
        mq_spawn(
            onError,
            onSuccess,
            async move {
                channel
                    .inner
                    .queue_declare(
                        queue.into(),
                        QueueDeclareOptions {
                            durable: true,
                            ..Default::default()
                        },
                        FieldTable::default(),
                    )
                    .await
                    .map_err(mq_error)?;
                Ok(MqValue::Unit)
            },
            |value| value,
        )
    })
}
pub fn Infra_Client_RabbitMq_RabbitMq__sendToQueueImpl(
    channel: Arc<Channel>,
    queue: String,
    content: String,
) -> MqValue {
    mq_aff(move |onError, onSuccess| {
        let channel = channel.clone();
        let queue = purust_core::purust_string_to_utf8_lossy(&queue);
        let content = purust_core::purust_string_to_utf8_lossy(&content);
        mq_spawn(
            onError,
            onSuccess,
            async move {
                // This is a regular channel, not a publisher-confirm channel. The
                // Aff completes after the transport accepted the publication.
                channel
                    .inner
                    .basic_publish(
                        "".into(),
                        queue.into(),
                        BasicPublishOptions::default(),
                        content.as_bytes(),
                        BasicProperties::default().with_delivery_mode(2),
                    )
                    .await
                    .map_err(mq_error)?
                    .await
                    .map_err(mq_error)?;
                Ok(MqValue::Unit)
            },
            |value| value,
        )
    })
}
pub fn Infra_Client_RabbitMq_RabbitMq__consumeImpl(
    channel: Arc<Channel>,
    queue: String,
    callback: MqCallback,
) -> MqValue {
    mq_aff(move |onError, onSuccess| {
        let channel = channel.clone();
        let queue = purust_core::purust_string_to_utf8_lossy(&queue);
        let callback = callback.clone();
        mq_spawn(
            onError,
            onSuccess,
            async move {
                let consumer = channel
                    .inner
                    .basic_consume(
                        queue.into(),
                        "".into(),
                        BasicConsumeOptions::default(),
                        FieldTable::default(),
                    )
                    .await
                    .map_err(mq_error)?;
                Ok(mq_box(Mutex::new(Some(consumer))))
            },
            move |value| {
                let consumer = value
                    .unwrap_class::<Mutex<Option<lapin::Consumer>>>()
                    .lock()
                    .unwrap()
                    .take()
                    .unwrap();
                mq_receive(consumer, callback.clone());
                MqValue::Unit
            },
        )
    })
}
pub fn Infra_Client_RabbitMq_RabbitMq__closeChannelImpl(channel: Arc<Channel>) -> MqValue {
    mq_aff(move |onError, onSuccess| {
        let channel = channel.clone();
        mq_spawn(
            onError,
            onSuccess,
            async move {
                channel
                    .inner
                    .close(200, "OK".into())
                    .await
                    .map_err(mq_error)?;
                Ok(MqValue::Unit)
            },
            |value| value,
        )
    })
}
pub fn Infra_Client_RabbitMq_RabbitMq__closeConnectionImpl(connection: Arc<Connection>) -> MqValue {
    mq_aff(move |onError, onSuccess| {
        let connection = connection.clone();
        mq_spawn(
            onError,
            onSuccess,
            async move {
                connection
                    .inner
                    .close(200, "OK".into())
                    .await
                    .map_err(mq_error)?;
                Ok(MqValue::Unit)
            },
            |value| value,
        )
    })
}
