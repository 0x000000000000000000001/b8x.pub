import amqp from "amqplib";

export const _createConnectionImpl =
  (newPromise) => (host) => (port) => (user) => (password) => () => {
    return newPromise((resolve, reject) => {
      (async () => {
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
      })()
        .then(resolve)
        .catch(reject);
    });
  };

export const _createChannelImpl = (newPromise) => (conn) => () => {
  return newPromise((resolve, reject) => {
    (async () => {
      return await conn.createChannel();
    })()
      .then(resolve)
      .catch(reject);
  });
};

export const _assertQueueImpl = (newPromise) => (ch) => (queue) => () => {
  return newPromise((resolve, reject) => {
    (async () => {
      await ch.assertQueue(queue, { durable: true });
    })()
      .then(resolve)
      .catch(reject);
  });
};

export const _sendToQueueImpl =
  (newPromise) => (ch) => (queue) => (content) => () => {
    return newPromise((resolve, reject) => {
      (async () => {
        const result = await ch.sendToQueue(queue, Buffer.from(content), {
          persistent: true,
        });
        if (!result) {
          throw new Error(`Failed to send to queue: ${queue}, ${content}`);
        }
      })()
        .then(resolve)
        .catch(reject);
    });
  };

export const _consumeImpl =
  (newPromise) => (ch) => (queue) => (onMessage) => () => {
    return newPromise((resolve, reject) => {
      (async () => {
        await ch.consume(queue, (msg) => {
          if (msg !== null) {
            onMessage(msg.content.toString())();
            ch.ack(msg);
          }
        });
      })()
        .then(resolve)
        .catch(reject);
    });
  };

export const _closeConnectionImpl = (newPromise) => (conn) => () => {
  return newPromise((resolve, reject) => {
    (async () => {
      return await conn.close();
    })()
      .then(resolve)
      .catch(reject);
  });
};

export const _closeChannelImpl = (newPromise) => (ch) => () => {
  return newPromise((resolve, reject) => {
    (async () => {
      return await ch.close();
    })()
      .then(resolve)
      .catch(reject);
  });
};
