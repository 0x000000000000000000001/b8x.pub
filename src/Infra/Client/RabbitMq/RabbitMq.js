import amqp from "amqplib";

// These SDK operations cannot be aborted through the previous Promise bridge.
const runAsync = (operation) => (onError, onSuccess) => {
  operation().then(onSuccess, onError);
  return (_cancelError, _onCancelError, onCancelSuccess) => onCancelSuccess();
};

export const _createConnectionImpl = (host) => (port) => (user) => (password) =>
  runAsync(async () => {
    return await amqp.connect({
      protocol: "amqp",
      hostname: host,
      port: port,
      username: user,
      password: password,
      locale: "en_US",
      frameMax: 0,
      heartbeat: 60,
      vhost: "/",
    });
  });

export const _createChannelImpl = (conn) =>
  runAsync(async () => {
    return await conn.createChannel();
  });

export const _assertQueueImpl = (ch) => (queue) =>
  runAsync(async () => {
    await ch.assertQueue(queue, { durable: true });
  });

export const _sendToQueueImpl = (ch) => (queue) => (content) =>
  runAsync(async () => {
    const result = await ch.sendToQueue(queue, Buffer.from(content), {
      persistent: true,
    });
    if (!result) {
      throw new Error(`Failed to send to queue: ${queue}, ${content}`);
    }
  });

export const _consumeImpl = (ch) => (queue) => (onMessage) =>
  runAsync(async () => {
    await ch.consume(queue, (msg) => {
      if (msg !== null) {
        onMessage(msg.content.toString());
        ch.ack(msg);
      }
    });
  });

export const _closeConnectionImpl = (conn) =>
  runAsync(async () => {
    await conn.close();
  });

export const _closeChannelImpl = (ch) =>
  runAsync(async () => {
    await ch.close();
  });
