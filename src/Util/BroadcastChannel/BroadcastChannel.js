export const make = name => () => new BroadcastChannel(name);
export const postMessage = channel => msg => () => channel.postMessage(msg);
export const onMessage = channel => callback => () => {
  channel.onmessage = event => {
    callback(event.data)();
  };
};
