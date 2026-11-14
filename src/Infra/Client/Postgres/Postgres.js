import pk from 'pg';

const { Pool } = pk;

// Cancellation preserves the existing promise bridge's non-cancelling contract.
const fromAsync = (action) => (onError, onSuccess) => {
  Promise.resolve().then(action).then(onSuccess, onError);
  return (_reason, _onCancelError, onCancelSuccess) => onCancelSuccess();
};

export const _createConnectionPoolHandle =
  (host) =>
  (port) =>
  (database) =>
  (user) =>
  (password) =>
  (idleTimeoutMillis) =>
  () => {
    const pool = new Pool({
      host,
      port,
      database,
      user,
      password,
      idleTimeoutMillis,
      max: 100,
    });
    pool.on('error', () => {
      /* Idle clients may fail while the database is dropped. */
    });
    return pool;
  };

export const _closeHandle = (handle) => fromAsync(() => handle.end());

// node-postgres already serializes object parameters with JSON.stringify.
export const _query = (_encodeJson) => (handle) => (query) => (params) =>
  fromAsync(async () => {
    const result = await handle.query(query, params);
    return result.rows;
  });

export const _queryCount = (_encodeJson) => (handle) => (query) => (params) =>
  fromAsync(async () => {
    const result = await handle.query(query, params);
    return result.rowCount;
  });

export const _escapeIdentifier = (identifier) =>
  '"' + identifier.replace(/"/g, '""') + '"';
export const _dedicate = (handle) => fromAsync(() => handle.connect());
export const _release = (handle) =>
  fromAsync(() => {
    handle.release();
  });
