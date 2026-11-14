export const onSignalImpl = (signal, callback) => {
    process.on(signal, callback);
};
