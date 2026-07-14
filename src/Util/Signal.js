export const _onSignal = (signal) => (callback) => () => {
    process.on(signal, () => {
        callback();
    });
};