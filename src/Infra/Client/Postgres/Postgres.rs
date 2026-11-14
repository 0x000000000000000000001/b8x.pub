use futures_util::TryStreamExt;
use purust_core::Value as PgValue;
use std::sync::{
    atomic::{AtomicUsize, Ordering},
    Arc, Mutex,
};
use std::time::{Duration, Instant};
use tokio::sync::{mpsc, oneshot, Notify, OwnedSemaphorePermit, Semaphore};
use tokio_postgres::{
    types::{FromSql, IsNull, ToSql, Type},
    Client as PgClient,
};

type PgResult = Result<PgValue, PgValue>;
const PG_POOL_LIMIT: usize = 100;

fn pg_error(message: impl Into<String>) -> PgValue {
    Purs_Effect_Exception::Effect_Exception_error(purust_core::purust_string_from_utf8(
        &message.into(),
    ))
}
fn pg_database_error(error: tokio_postgres::Error) -> PgValue {
    pg_error(
        error
            .as_db_error()
            .map(|error| error.message().to_owned())
            .unwrap_or_else(|| error.to_string()),
    )
}
fn pg_record(fields: impl IntoIterator<Item = (String, PgValue)>) -> PgValue {
    let mut record = purust_core::RecordFields::new();
    for (key, value) in fields {
        record.insert(key, value);
    }
    PgValue::DynamicRecord(perceus_ptr::PerceusPtr::new(record))
}
fn pg_handle(handle: Arc<Handle>) -> PgValue {
    PgValue::Class(Arc::new(handle))
}
fn pg_unbox_handle(value: &PgValue) -> Arc<Handle> {
    value.unwrap_class::<Arc<Handle>>().clone()
}
fn pg_effect(action: impl Fn() -> PgValue + Send + Sync + 'static) -> PgValue {
    PgValue::Func1(purust_core::Func1::Shared(Arc::new(move |_| action())))
}
fn pg_aff_future<F>(future: F) -> PgValue
where
    F: std::future::Future<Output = PgResult> + Send,
    F: 'static,
{
    let future = Mutex::new(Some(future));
    PgValue::Func2(purust_core::Func2::Shared(Arc::new(
        move |on_error, on_success| {
            Purs_Effect_Aff::purust_aff_spawn_native(
                future.lock().unwrap().take().unwrap(),
                move |result| {
                    match result {
                        Ok(value) => on_success.unwrap_func1()(value),
                        Err(error) => on_error.unwrap_func1()(error),
                    };
                },
            );
            PgValue::Func3(purust_core::Func3::Shared(Arc::new(
                move |_, _, on_success| on_success.unwrap_func1()(PgValue::Unit),
            )))
        },
    )))
}

fn pg_async_action(action: impl Fn() -> PgValue + Send + Sync + 'static) -> PgValue {
    PgValue::Func2(purust_core::Func2::Shared(Arc::new(
        move |on_error, on_success| action().unwrap_func2()(on_error, on_success),
    )))
}

struct PgPoolState {
    closing: bool,
    idle: Vec<(Instant, PgClient)>,
}
pub struct PgPool {
    config: tokio_postgres::Config,
    idle_timeout: Duration,
    slots: Arc<Semaphore>,
    state: Mutex<PgPoolState>,
    open: AtomicUsize,
    changed: Notify,
}
struct PgLease {
    pool: Arc<PgPool>,
    client: Option<PgClient>,
    _permit: OwnedSemaphorePermit,
}
impl Drop for PgLease {
    fn drop(&mut self) {
        let client = self.client.take().unwrap();
        let mut state = self.pool.state.lock().unwrap();
        if state.closing || client.is_closed() {
            drop(state);
            drop(client);
            return;
        }
        state.idle.push((Instant::now(), client));
        drop(state);
        if !self.pool.idle_timeout.is_zero() {
            let pool = Arc::downgrade(&self.pool);
            let delay = self.pool.idle_timeout;
            tokio::spawn(async move {
                tokio::time::sleep(delay).await;
                if let Some(pool) = pool.upgrade() {
                    pool.expire_idle();
                }
            });
        }
    }
}
impl PgPool {
    fn expire_idle(&self) {
        self.state.lock().unwrap().idle.retain(|(at, client)| {
            !client.is_closed() && (self.idle_timeout.is_zero() || at.elapsed() < self.idle_timeout)
        });
    }
    async fn checkout(self: &Arc<Self>) -> Result<PgLease, PgValue> {
        let permit = self
            .slots
            .clone()
            .acquire_owned()
            .await
            .map_err(|_| pg_error("Cannot use a pool after calling end on the pool"))?;
        self.expire_idle();
        let idle = {
            let mut state = self.state.lock().unwrap();
            if state.closing {
                return Err(pg_error("Cannot use a pool after calling end on the pool"));
            }
            state.idle.pop().map(|(_, client)| client)
        };
        let client = match idle {
            Some(client) => client,
            None => {
                let (client, connection) = self
                    .config
                    .connect(tokio_postgres::NoTls)
                    .await
                    .map_err(pg_database_error)?;
                self.open.fetch_add(1, Ordering::AcqRel);
                let pool = self.clone();
                tokio::spawn(async move {
                    // Queries receive their connection errors through the client.
                    // Idle disconnects are deliberately quiet, as in the JS FFI.
                    let _ = connection.await;
                    pool.open.fetch_sub(1, Ordering::AcqRel);
                    pool.changed.notify_one();
                });
                client
            }
        };
        let lease = PgLease {
            pool: self.clone(),
            client: Some(client),
            _permit: permit,
        };
        if self.state.lock().unwrap().closing {
            return Err(pg_error("Cannot use a pool after calling end on the pool"));
        }
        Ok(lease)
    }
    fn begin_close(&self) -> Result<(), PgValue> {
        let mut state = self.state.lock().unwrap();
        if state.closing {
            return Err(pg_error("Called end on pool more than once"));
        }
        state.closing = true;
        self.slots.close();
        state.idle.clear();
        Ok(())
    }
    async fn finish_close(&self) -> PgResult {
        loop {
            let changed = self.changed.notified();
            // All permits must be returned, including a connect still in flight.
            if self.open.load(Ordering::Acquire) == 0
                && self.slots.available_permits() == PG_POOL_LIMIT
            {
                break;
            }
            tokio::select! { _ = changed => {}, _ = tokio::time::sleep(Duration::from_millis(1)) => {} }
        }
        Ok(PgValue::Unit)
    }
}
enum PgCommand {
    Query(String, Vec<PgParam>, bool, oneshot::Sender<PgResult>),
    Release(oneshot::Sender<PgResult>),
}
pub struct PgDedicated {
    sender: Mutex<Option<mpsc::UnboundedSender<PgCommand>>>,
}
pub enum Handle {
    Pool(Arc<PgPool>),
    Dedicated(PgDedicated),
}
impl PgDedicated {
    fn query(
        &self,
        sql: String,
        params: Vec<PgParam>,
        count: bool,
    ) -> Result<oneshot::Receiver<PgResult>, PgValue> {
        let (reply, result) = oneshot::channel();
        self.sender
            .lock()
            .unwrap()
            .as_ref()
            .ok_or_else(|| pg_error("Client was released"))?
            .send(PgCommand::Query(sql, params, count, reply))
            .map_err(|_| pg_error("Client connection ended"))?;
        Ok(result)
    }
    fn release(&self) -> Result<oneshot::Receiver<PgResult>, PgValue> {
        let (reply, result) = oneshot::channel();
        self.sender
            .lock()
            .unwrap()
            .take()
            .ok_or_else(|| {
                pg_error("Release called on client which has already been released to the pool")
            })?
            .send(PgCommand::Release(reply))
            .map_err(|_| pg_error("Client connection ended"))?;
        Ok(result)
    }
}
async fn pg_dedicate(pool: Arc<PgPool>) -> PgResult {
    let lease = pool.checkout().await?;
    let (sender, mut receiver) = mpsc::unbounded_channel();
    tokio::spawn(async move {
        while let Some(command) = receiver.recv().await {
            match command {
                PgCommand::Query(sql, params, count, reply) => {
                    let result =
                        pg_query(lease.client.as_ref().unwrap(), &sql, &params, count).await;
                    let _ = reply.send(result);
                }
                PgCommand::Release(reply) => {
                    drop(lease);
                    let _ = reply.send(Ok(PgValue::Unit));
                    return;
                }
            }
        }
        drop(lease);
    });
    Ok(pg_handle(Arc::new(Handle::Dedicated(PgDedicated {
        sender: Mutex::new(Some(sender)),
    }))))
}
async fn pg_reply(result: Result<oneshot::Receiver<PgResult>, PgValue>) -> PgResult {
    result?
        .await
        .map_err(|_| pg_error("Client connection ended before completing its operation"))?
}

// Parameters use PostgreSQL's text format, never SQL interpolation. This also
// preserves node-pg's array/object conversion without guessing parameter OIDs.
#[derive(Debug)]
struct PgParam(Option<String>);
impl ToSql for PgParam {
    fn to_sql(
        &self,
        _: &Type,
        output: &mut bytes::BytesMut,
    ) -> Result<IsNull, Box<dyn std::error::Error + Send + Sync>> {
        match &self.0 {
            None => Ok(IsNull::Yes),
            Some(value) => {
                output.extend_from_slice(value.as_bytes());
                Ok(IsNull::No)
            }
        }
    }
    fn accepts(_: &Type) -> bool {
        true
    }
    fn encode_format(&self, _: &Type) -> tokio_postgres::types::Format {
        tokio_postgres::types::Format::Text
    }
    tokio_postgres::types::to_sql_checked!();
}
fn pg_json_quote(value: &str) -> String {
    let units = purust_core::purust_string_to_utf16(value);
    let escaped: String = units.iter().map(|unit| format!("\\u{unit:04x}")).collect();
    format!("\"{escaped}\"")
}
fn pg_json(value: &PgValue) -> Result<String, PgValue> {
    Ok(match value.resolve() {
        PgValue::Null | PgValue::Unit => "null".to_owned(),
        PgValue::Bool(v) => v.to_string(),
        PgValue::Int(v) => v.to_string(),
        PgValue::Number(v) => {
            if v.is_finite() {
                ryu_js::Buffer::new().format_finite(*v).to_owned()
            } else {
                "null".to_owned()
            }
        }
        PgValue::String(v) => pg_json_quote(v),
        PgValue::Char(v) => pg_json_quote(&v.to_string()),
        PgValue::Array(values) => format!(
            "[{}]",
            values
                .iter()
                .map(pg_json)
                .collect::<Result<Vec<_>, _>>()?
                .join(",")
        ),
        PgValue::Class(native) => {
            let object = native
                .downcast_ref::<Arc<purust_core::SharedRecord>>()
                .ok_or_else(|| pg_error("Unsupported opaque PostgreSQL JSON parameter"))?;
            pg_json(&pg_record(object.entries()))?
        }
        _ => {
            let fields = value
                .__purust_record_fields()
                .ok_or_else(|| pg_error("Unsupported opaque PostgreSQL JSON parameter"))?;
            let mut entries = Vec::new();
            for (key, value) in fields.entries() {
                if !matches!(value.resolve(), PgValue::Unit) {
                    entries.push(format!("{}:{}", pg_json_quote(&key), pg_json(&value)?));
                }
            }
            format!("{{{}}}", entries.join(","))
        }
    })
}
fn pg_param(value: &PgValue) -> Result<Option<String>, PgValue> {
    Ok(match value.resolve() {
        PgValue::Null | PgValue::Unit => None,
        PgValue::String(v) => Some(purust_core::purust_string_to_utf8_lossy(v)),
        PgValue::Char(v) => Some(purust_core::purust_string_to_utf8_lossy(&v.to_string())),
        PgValue::Int(v) => Some(v.to_string()),
        PgValue::Bool(v) => Some(v.to_string()),
        PgValue::Number(v) => Some(if v.is_nan() {
            "NaN".to_owned()
        } else if *v == f64::INFINITY {
            "Infinity".to_owned()
        } else if *v == f64::NEG_INFINITY {
            "-Infinity".to_owned()
        } else {
            ryu_js::Buffer::new().format_finite(*v).to_owned()
        }),
        PgValue::Array(values) => {
            let mut parts = Vec::new();
            for value in values.iter() {
                parts.push(match pg_param(value)? {
                    None => "NULL".to_owned(),
                    Some(v) if matches!(value.resolve(), PgValue::Array(_)) => v,
                    Some(v) => format!("\"{}\"", v.replace('\\', "\\\\").replace('"', "\\\"")),
                });
            }
            Some(format!("{{{}}}", parts.join(",")))
        }
        _ => Some(pg_json(value)?),
    })
}
fn pg_from_json(value: serde_json::Value) -> PgValue {
    match value {
        serde_json::Value::Null => PgValue::Null,
        serde_json::Value::Bool(v) => PgValue::Bool(v),
        serde_json::Value::Number(v) => PgValue::Number(v.as_f64().unwrap()),
        serde_json::Value::String(v) => PgValue::String(purust_core::purust_string_from_utf8(&v)),
        serde_json::Value::Array(v) => {
            PgValue::Array(Arc::new(v.into_iter().map(pg_from_json).collect()))
        }
        serde_json::Value::Object(v) => pg_record(v.into_iter().map(|(key, value)| {
            (
                purust_core::purust_string_from_utf8(&key),
                pg_from_json(value),
            )
        })),
    }
}
type PgDecodeError = Box<dyn std::error::Error + Send + Sync>;
fn pg_numeric(bytes: &[u8]) -> Result<String, PgDecodeError> {
    if bytes.len() < 8 {
        return Err("Invalid numeric header".into());
    }
    let count = i16::from_be_bytes(bytes[0..2].try_into()?) as usize;
    let weight = i16::from_be_bytes(bytes[2..4].try_into()?) as i32;
    let sign = u16::from_be_bytes(bytes[4..6].try_into()?);
    let scale = u16::from_be_bytes(bytes[6..8].try_into()?) as usize;
    if let Some(special) = match sign {
        0xc000 => Some("NaN"),
        0xd000 => Some("Infinity"),
        0xf000 => Some("-Infinity"),
        _ => None,
    } {
        return Ok(special.to_owned());
    }
    if bytes.len() != 8 + count * 2 {
        return Err("Invalid numeric digits".into());
    }
    let digits: Vec<_> = bytes[8..]
        .chunks_exact(2)
        .map(|b| u16::from_be_bytes([b[0], b[1]]))
        .collect();
    if digits.iter().any(|d| *d >= 10000) || !matches!(sign, 0 | 0x4000) {
        return Err("Invalid numeric value".into());
    }
    let digit = |index: i32| {
        if index < 0 {
            0
        } else {
            digits.get(index as usize).copied().unwrap_or(0)
        }
    };
    let mut result = if sign == 0x4000 {
        "-".to_owned()
    } else {
        String::new()
    };
    if weight < 0 {
        result.push('0');
    } else {
        for index in 0..=weight {
            result.push_str(&if index == 0 {
                digit(index).to_string()
            } else {
                format!("{:04}", digit(index))
            });
        }
    }
    if scale > 0 {
        let mut fraction = String::new();
        for index in 0..scale.div_ceil(4) {
            fraction.push_str(&format!("{:04}", digit(weight + 1 + index as i32)));
        }
        fraction.truncate(scale);
        result.push('.');
        result.push_str(&fraction);
    }
    Ok(result)
}
struct PgCell(PgValue);
impl<'a> FromSql<'a> for PgCell {
    fn accepts(_: &Type) -> bool {
        true
    }
    fn from_sql_null(_: &Type) -> Result<Self, PgDecodeError> {
        Ok(Self(PgValue::Null))
    }
    fn from_sql(ty: &Type, raw: &'a [u8]) -> Result<Self, PgDecodeError> {
        Ok(Self(pg_decode(ty, raw)?))
    }
}
fn pg_decode(ty: &Type, raw: &[u8]) -> Result<PgValue, PgDecodeError> {
    if let tokio_postgres::types::Kind::Domain(inner) = ty.kind() {
        return pg_decode(inner, raw);
    }
    if let tokio_postgres::types::Kind::Array(inner) = ty.kind() {
        return pg_array(inner, raw);
    }
    Ok(match ty.oid() {
        16 => PgValue::Bool(raw == [1]),
        21 => PgValue::Int(i16::from_be_bytes(raw.try_into()?) as i64),
        23 => PgValue::Int(i32::from_be_bytes(raw.try_into()?) as i64),
        26 => PgValue::Int(u32::from_be_bytes(raw.try_into()?) as i64),
        20 => PgValue::String(i64::from_be_bytes(raw.try_into()?).to_string()),
        700 => PgValue::Number(f32::from_be_bytes(raw.try_into()?) as f64),
        701 => PgValue::Number(f64::from_be_bytes(raw.try_into()?)),
        1700 => PgValue::String(pg_numeric(raw)?),
        114 => pg_from_json(serde_json::from_slice(raw)?),
        3802 if raw.first() == Some(&1) => pg_from_json(serde_json::from_slice(&raw[1..])?),
        25 | 1043 | 1042 | 19 | 18 | 142 | 705 | 2278 | 4072 => PgValue::String(
            purust_core::purust_string_from_utf8(std::str::from_utf8(raw)?),
        ),
        2950 if raw.len() == 16 => {
            let hex: String = raw.iter().map(|b| format!("{b:02x}")).collect();
            PgValue::String(format!(
                "{}-{}-{}-{}-{}",
                &hex[..8],
                &hex[8..12],
                &hex[12..16],
                &hex[16..20],
                &hex[20..]
            ))
        }
        _ if matches!(ty.kind(), tokio_postgres::types::Kind::Enum(_)) => PgValue::String(
            purust_core::purust_string_from_utf8(std::str::from_utf8(raw)?),
        ),
        _ => {
            return Err(format!(
                "Unsupported PostgreSQL result type {} (OID {})",
                ty.name(),
                ty.oid()
            )
            .into())
        }
    })
}
fn pg_array(inner: &Type, mut bytes: &[u8]) -> Result<PgValue, PgDecodeError> {
    fn integer(bytes: &mut &[u8]) -> Result<i32, PgDecodeError> {
        if bytes.len() < 4 {
            return Err("Invalid array data".into());
        }
        let value = i32::from_be_bytes(bytes[..4].try_into()?);
        *bytes = &bytes[4..];
        Ok(value)
    }
    fn level(inner: &Type, dims: &[usize], bytes: &mut &[u8]) -> Result<PgValue, PgDecodeError> {
        let mut values = Vec::new();
        for _ in 0..dims[0] {
            values.push(if dims.len() > 1 {
                level(inner, &dims[1..], bytes)?
            } else {
                let size = integer(bytes)?;
                if size == -1 {
                    PgValue::Null
                } else {
                    if size < 0 || size as usize > bytes.len() {
                        return Err("Invalid array element".into());
                    }
                    let value = pg_decode(inner, &bytes[..size as usize])?;
                    *bytes = &bytes[size as usize..];
                    value
                }
            });
        }
        Ok(PgValue::Array(Arc::new(values)))
    }
    let count = integer(&mut bytes)?;
    if !(0..=6).contains(&count) {
        return Err("Invalid array dimensions".into());
    }
    let _nulls = integer(&mut bytes)?;
    let _oid = integer(&mut bytes)?;
    let mut dims = Vec::new();
    for _ in 0..count {
        let size = integer(&mut bytes)?;
        if size < 0 {
            return Err("Invalid array length".into());
        }
        dims.push(size as usize);
        let _lower_bound = integer(&mut bytes)?;
    }
    let value = if dims.is_empty() {
        PgValue::Array(Arc::new(Vec::new()))
    } else {
        level(inner, &dims, &mut bytes)?
    };
    if !bytes.is_empty() {
        return Err("Trailing array data".into());
    }
    Ok(value)
}

// Detect command boundaries without rewriting SQL, parameters or dollar bodies.
fn pg_multiple_statements(sql: &str) -> bool {
    let b = sql.as_bytes();
    let mut i = 0;
    let mut ended = false;
    let mut has_statement = false;
    while i < b.len() {
        if b[i].is_ascii_whitespace() {
            i += 1;
            continue;
        }
        if b[i..].starts_with(b"--") {
            while i < b.len() && b[i] != b'\n' {
                i += 1;
            }
            continue;
        }
        if b[i..].starts_with(b"/*") {
            i += 2;
            let mut depth = 1;
            while i < b.len() && depth > 0 {
                if b[i..].starts_with(b"/*") {
                    depth += 1;
                    i += 2;
                } else if b[i..].starts_with(b"*/") {
                    depth -= 1;
                    i += 2;
                } else {
                    i += 1;
                }
            }
            continue;
        }
        if b[i] == b';' {
            ended = has_statement;
            i += 1;
            continue;
        }
        if ended {
            return true;
        }
        has_statement = true;
        if b[i] == b'\'' || b[i] == b'"' {
            let quote = b[i];
            let escaped = quote == b'\'' && i > 0 && matches!(b[i - 1], b'e' | b'E');
            i += 1;
            while i < b.len() {
                if escaped && b[i] == b'\\' {
                    i = (i + 2).min(b.len());
                } else if b[i] == quote {
                    i += 1;
                    if b.get(i) == Some(&quote) {
                        i += 1;
                    } else {
                        break;
                    }
                } else {
                    i += 1;
                }
            }
        } else if b[i] == b'$' {
            let start = i;
            i += 1;
            while i < b.len() && (b[i].is_ascii_alphanumeric() || b[i] == b'_') {
                i += 1;
            }
            if b.get(i) == Some(&b'$') {
                let marker = &sql[start..=i];
                i += 1;
                if let Some(end) = sql[i..].find(marker) {
                    i += end + marker.len();
                } else {
                    i = b.len();
                }
            }
        } else {
            i += 1;
        }
    }
    false
}
async fn pg_query(client: &PgClient, sql: &str, params: &[PgParam], count: bool) -> PgResult {
    if params.is_empty() && pg_multiple_statements(sql) {
        client.batch_execute(sql).await.map_err(pg_database_error)?;
        // node-pg returns an array of Results; the original FFI reads .rows/.rowCount
        // from that array, so both are undefined. These batches are used for DDL.
        return Ok(PgValue::Unit);
    }
    let stream = client
        .query_raw(sql, params.iter())
        .await
        .map_err(pg_database_error)?;
    let mut stream = std::pin::pin!(stream);
    let mut rows = Vec::new();
    while let Some(row) = stream.try_next().await.map_err(pg_database_error)? {
        if !count {
            let fields = row
                .columns()
                .iter()
                .enumerate()
                .map(|(index, column)| {
                    row.try_get::<_, PgCell>(index)
                        .map(|cell| (purust_core::purust_string_from_utf8(column.name()), cell.0))
                })
                .collect::<Result<Vec<_>, _>>()
                .map_err(pg_database_error)?;
            rows.push(pg_record(fields));
        }
    }
    if count {
        Ok(stream
            .rows_affected()
            .map(|n| PgValue::Int(n as i64))
            .unwrap_or(PgValue::Null))
    } else {
        Ok(PgValue::Array(Arc::new(rows)))
    }
}

pub fn Infra_Client_Postgres_Postgres__createConnectionPoolHandle(
    host: String,
    port: i64,
    database: String,
    user: String,
    password: String,
    idle: i64,
) -> crate::UnknownType {
    pg_effect(move || {
        let mut config = tokio_postgres::Config::new();
        config.host(purust_core::purust_string_to_utf8_lossy(&host));
        config.port(u16::try_from(port).expect("PostgreSQL port must fit u16"));
        config.dbname(purust_core::purust_string_to_utf8_lossy(&database));
        config.user(purust_core::purust_string_to_utf8_lossy(&user));
        config.password(purust_core::purust_string_to_utf8_lossy(&password));
        pg_handle(Arc::new(Handle::Pool(Arc::new(PgPool {
            config,
            idle_timeout: Duration::from_millis(idle.max(0) as u64),
            slots: Arc::new(Semaphore::new(PG_POOL_LIMIT)),
            state: Mutex::new(PgPoolState {
                closing: false,
                idle: Vec::new(),
            }),
            open: AtomicUsize::new(0),
            changed: Notify::new(),
        }))))
    })
}
fn pg_query_effect(handle: Arc<Handle>, sql: String, params: PgValue, count: bool) -> PgValue {
    pg_async_action(move || {
        let converted = params
            .unwrap_array()
            .iter()
            .map(|value| pg_param(value).map(PgParam))
            .collect::<Result<Vec<_>, _>>();
        let sql = purust_core::purust_string_to_utf8_lossy(&sql);
        match converted {
            Err(error) => pg_aff_future(async move { Err(error) }),
            Ok(params) => match handle.as_ref() {
                Handle::Pool(pool) => {
                    let pool = pool.clone();
                    pg_aff_future(async move {
                        let lease = pool.checkout().await?;
                        pg_query(lease.client.as_ref().unwrap(), &sql, &params, count).await
                    })
                }
                Handle::Dedicated(client) => {
                    // Enqueue synchronously, before spawning the waiting future.
                    let result = client.query(sql, params, count);
                    pg_aff_future(pg_reply(result))
                }
            },
        }
    })
}
pub fn Infra_Client_Postgres_Postgres__query(
    _encode_json: purust_core::Func1<PgValue, String>,
    handle: Arc<Handle>,
    sql: String,
    params: crate::UnknownType,
) -> crate::UnknownType {
    pg_query_effect(handle, sql, params, false)
}
pub fn Infra_Client_Postgres_Postgres__queryCount(
    _encode_json: purust_core::Func1<PgValue, String>,
    handle: Arc<Handle>,
    sql: String,
    params: crate::UnknownType,
) -> crate::UnknownType {
    pg_query_effect(handle, sql, params, true)
}
pub fn Infra_Client_Postgres_Postgres__escapeIdentifier(identifier: String) -> String {
    format!("\"{}\"", identifier.replace('"', "\"\""))
}
pub fn Infra_Client_Postgres_Postgres__dedicate(handle: crate::UnknownType) -> crate::UnknownType {
    pg_async_action(move || match pg_unbox_handle(&handle).as_ref() {
        Handle::Pool(pool) => pg_aff_future(pg_dedicate(pool.clone())),
        _ => pg_aff_future(async { Err(pg_error("Expected a connection pool")) }),
    })
}
pub fn Infra_Client_Postgres_Postgres__release(handle: crate::UnknownType) -> crate::UnknownType {
    pg_async_action(move || match pg_unbox_handle(&handle).as_ref() {
        Handle::Dedicated(client) => pg_aff_future(pg_reply(client.release())),
        _ => pg_aff_future(async { Err(pg_error("Expected a dedicated connection")) }),
    })
}
pub fn Infra_Client_Postgres_Postgres__closeHandle(handle: Arc<Handle>) -> crate::UnknownType {
    pg_async_action(move || match handle.as_ref() {
        Handle::Pool(pool) => {
            let pool = pool.clone();
            let started = pool.begin_close();
            pg_aff_future(async move {
                started?;
                pool.finish_close().await
            })
        }
        _ => pg_aff_future(async { Err(pg_error("Expected a connection pool")) }),
    })
}
