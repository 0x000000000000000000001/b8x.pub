import pk from 'pg';

const { Pool } = pk;

export const _createConnectionPoolHandle = (host) => (port) => (database) => (user) => (password) => (idleTimeoutMs) => () => {
  const pool = new Pool({
    host: host,
    port: port,
    database: database,
    user: user,
    password: password,
    idleTimeoutMillis: idleTimeoutMs,
    max: 100,
  });
  pool.on("error", () => { /* Ignore idle client errors on drop database */ });
  return pool;
};

export const _closeHandle = (handle) => async () => {
  await handle.end();
};

export const _query = (handle) => (queryString) => (params) => async () => {
  const res = await handle.query(queryString, params);
  return res.rows;
};

export const _queryCount = (handle) => (query) => (params) => async () => {
  const result = await handle.query(query, params);
  return result.rowCount;
};

export const _escapeIdentifier = (identifier) => {
  return '"' + identifier.replace(/"/g, '""') + '"';
};

export const _dedicate = (handle) => async () => {
  return await handle.connect();
};

export const _release = (dedicatedHandle) => async () => {
  dedicatedHandle.release();
};
