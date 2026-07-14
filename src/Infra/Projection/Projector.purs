module Infra.Projection.Projector where

import Proem

import Control.Monad.Except as Control.Monad.Except
import Control.Monad.Rec.Class (Step(..), tailRecM)
import Core.Event.Event (LoadedEvent)
import Core.Mod.Projection.Pair (Key)
import Core.Mod.Projection.Projection (class IsProjection, play)
import Data.Array as Array
import Data.Either (Either(..))
import Data.Generic.Rep (class Generic)
import Data.Maybe (Maybe(..))
import Data.Newtype (unwrap)
import Data.String (Pattern(..), Replacement(..), replaceAll)
import Data.Symbol (class IsSymbol)
import Data.Traversable (traverse_)
import Effect (Effect)
import Effect.Aff (delay, Milliseconds(..), attempt)
import Foreign as Foreign
import Infra.Cache.Fs.Cache (cacheDir)
import Infra.Client.Postgres.Postgres (READER_POSTGRES_EDGE_CLIENT, READER_POSTGRES_STORE_CLIENT, askEdgeConfig)
import Infra.Client.Postgres.Postgres as Postgres
import Infra.EventStore.Postgres.EventStore (loadProjectionEvents)
import Infra.Projection.CopyOnWrite (CopyOnWrite, ProjectionPersist, persist)
import Node.Encoding (Encoding(UTF8))
import Node.FS.Aff as FS
import Prim.Row as Row
import Prim.Symbol (class Append)
import Promise.Aff (Promise, toAffE)
import Run (AFF, EFFECT, Run)
import Run.State as Run
import Type.Row (type (+))
import Util.Aff (ʌ')
import Util.Json.TaggedSum (genericReadImplWithDefaultOpt, genericWriteImplWithDefaultOpt)
import Util.Log.Info (info)
import Util.Signal (READER_SIGNAL_REF, considerSignal)
import Util.Type.Limit (Limit(..))
import Util.Type.String.String (caseToSnake)
import Util.Type.String.ToString (class ToString)
import Yoga.JSON (class ReadForeign, class WriteForeign, readImpl, writeImpl, readJSON, writeJSON)

projectionSchemaName :: ∀ @name. IsSymbol name => String
projectionSchemaName = "proj_" <> caseToSnake (ᴠ @name)

-- | Run projection in infinite loop
project'
  :: ∀ @p name opsEffSym opsEff copyOnWriteStateEffSym copyOnWritePersistEffSym fx
   . IsProjection p name opsEffSym opsEff _ _ _ _
  => IsSymbol name
  => IsSymbol opsEffSym
  => IsSymbol copyOnWriteStateEffSym
  => IsSymbol copyOnWritePersistEffSym
  => Append name "ProjectionWriteCopyState" copyOnWriteStateEffSym
  => Append name "ProjectionWriteCopyPersist" copyOnWritePersistEffSym
  => Row.Union opsEff _ (READER_SIGNAL_REF + READER_POSTGRES_EDGE_CLIENT + READER_POSTGRES_STORE_CLIENT + EFFECT + AFF + fx)
  => Row.Cons copyOnWriteStateEffSym (Run.State CopyOnWrite) _ (READER_SIGNAL_REF + READER_POSTGRES_EDGE_CLIENT + READER_POSTGRES_STORE_CLIENT + EFFECT + AFF + fx)
  => Row.Cons copyOnWritePersistEffSym ProjectionPersist _ (READER_SIGNAL_REF + READER_POSTGRES_EDGE_CLIENT + READER_POSTGRES_STORE_CLIENT + EFFECT + AFF + fx)
  => Limit Int
  -> Limit Int
  -> Run (READER_SIGNAL_REF + READER_POSTGRES_EDGE_CLIENT + READER_POSTGRES_STORE_CLIENT + EFFECT + AFF + fx) Ɩ
  -> Run (READER_SIGNAL_REF + READER_POSTGRES_EDGE_CLIENT + READER_POSTGRES_STORE_CLIENT + EFFECT + AFF + fx) Ɩ
project' readBatchSize writeBatchSize onLockAcquired = do
  ensureProjectionsTable (projectionSchemaName @name)

  loop @p readBatchSize writeBatchSize onLockAcquired

-- | Run projection once
project
  :: ∀ @p name opsEffSym opsEff copyOnWriteStateEffSym copyOnWritePersistEffSym fx
   . IsProjection p name opsEffSym opsEff _ _ _ _
  => IsSymbol name
  => IsSymbol opsEffSym
  => IsSymbol copyOnWriteStateEffSym
  => IsSymbol copyOnWritePersistEffSym
  => Append name "ProjectionWriteCopyState" copyOnWriteStateEffSym
  => Append name "ProjectionWriteCopyPersist" copyOnWritePersistEffSym
  => Row.Union opsEff _ (READER_POSTGRES_EDGE_CLIENT + READER_POSTGRES_STORE_CLIENT + EFFECT + AFF + fx)
  => Row.Cons copyOnWriteStateEffSym (Run.State CopyOnWrite) _ (READER_POSTGRES_EDGE_CLIENT + READER_POSTGRES_STORE_CLIENT + EFFECT + AFF + fx)
  => Row.Cons copyOnWritePersistEffSym ProjectionPersist _ (READER_POSTGRES_EDGE_CLIENT + READER_POSTGRES_STORE_CLIENT + EFFECT + AFF + fx)
  => Limit Int
  -> Limit Int
  -> Run (READER_POSTGRES_EDGE_CLIENT + READER_POSTGRES_STORE_CLIENT + EFFECT + AFF + fx) Boolean
project readBatchSize writeBatchSize = do
  checkpoint <- getCheckpoint (projectionSchemaName @name)

  events <- loadProjectionEvents checkpoint readBatchSize

  if events == [] then η false
  else do
    let
      chunks = case writeBatchSize of
        Finite size -> chunk size events
        Infinite -> [ events ]

    traverse_ (processChunk @p) chunks

    η true

-- | Useful when you want to project synchronously (e.g. in tests, or local development).
project_
  :: ∀ @p name opsEffSym opsEff copyOnWriteStateEffSym copyOnWritePersistEffSym fx
   . IsProjection p name opsEffSym opsEff _ _ _ _
  => IsSymbol name
  => IsSymbol opsEffSym
  => IsSymbol copyOnWriteStateEffSym
  => IsSymbol copyOnWritePersistEffSym
  => Append name "ProjectionWriteCopyState" copyOnWriteStateEffSym
  => Append name "ProjectionWriteCopyPersist" copyOnWritePersistEffSym
  => Row.Union opsEff _ (READER_POSTGRES_EDGE_CLIENT + READER_POSTGRES_STORE_CLIENT + EFFECT + AFF + fx)
  => Row.Cons copyOnWriteStateEffSym (Run.State CopyOnWrite) _ (READER_POSTGRES_EDGE_CLIENT + READER_POSTGRES_STORE_CLIENT + EFFECT + AFF + fx)
  => Row.Cons copyOnWritePersistEffSym ProjectionPersist _ (READER_POSTGRES_EDGE_CLIENT + READER_POSTGRES_STORE_CLIENT + EFFECT + AFF + fx)
  => Run (READER_POSTGRES_EDGE_CLIENT + READER_POSTGRES_STORE_CLIENT + EFFECT + AFF + fx) Ɩ
project_ = ø $ project @p Infinite Infinite

loop
  :: ∀ @p name opsEffSym opsEff copyOnWriteStateEffSym copyOnWritePersistEffSym fx
   . IsProjection p name opsEffSym opsEff _ _ _ _
  => IsSymbol name
  => IsSymbol opsEffSym
  => IsSymbol copyOnWriteStateEffSym
  => IsSymbol copyOnWritePersistEffSym
  => Append name "ProjectionWriteCopyState" copyOnWriteStateEffSym
  => Append name "ProjectionWriteCopyPersist" copyOnWritePersistEffSym
  => Row.Union opsEff _ (READER_SIGNAL_REF + READER_POSTGRES_EDGE_CLIENT + READER_POSTGRES_STORE_CLIENT + EFFECT + AFF + fx)
  => Row.Cons copyOnWriteStateEffSym (Run.State CopyOnWrite) _ (READER_SIGNAL_REF + READER_POSTGRES_EDGE_CLIENT + READER_POSTGRES_STORE_CLIENT + EFFECT + AFF + fx)
  => Row.Cons copyOnWritePersistEffSym ProjectionPersist _ (READER_SIGNAL_REF + READER_POSTGRES_EDGE_CLIENT + READER_POSTGRES_STORE_CLIENT + EFFECT + AFF + fx)
  => Limit Int
  -> Limit Int
  -> Run (READER_SIGNAL_REF + READER_POSTGRES_EDGE_CLIENT + READER_POSTGRES_STORE_CLIENT + EFFECT + AFF + fx) Ɩ
  -> Run (READER_SIGNAL_REF + READER_POSTGRES_EDGE_CLIENT + READER_POSTGRES_STORE_CLIENT + EFFECT + AFF + fx) Ɩ
loop readBatchSize writeBatchSize onLockAcquired = waitForLock *> go
  where
  considerSignal' = considerSignal (Just $ "[" <> ᴠ @name <> "] ") $ setProjectionState (projectionSchemaName @name) Idle

  waitForLock = do
    info $ "[" <> ᴠ @name <> "] Waiting for lock acquirement..."

    tailRecM waitForLockLoop ι

  waitForLockLoop _ = do
    considerSignal (Just $ "[" <> ᴠ @name <> "] ") $ ηι

    acquired <- tryAdvisoryLock (projectionSchemaName @name)

    if acquired then η $ Done ι
    else do
      ʌ' $ delay $ Milliseconds 250.0
      η $ Loop ι

  go = do
    info $ "[" <> ᴠ @name <> "] Acquired lock. Supervising and processing events..."

    onLockAcquired

    setProjectionState (projectionSchemaName @name) Running

    tailRecM goLoop ι

  goLoop _ = do
    considerSignal'

    didSomething <- project @p readBatchSize writeBatchSize

    considerSignal'

    when (not didSomething)
      (ʌ' $ delay $ Milliseconds 100.0)

    considerSignal'

    η $ Loop ι

chunk :: ∀ a. Int -> Array a -> Array (Array a)
chunk size xs =
  if Array.length xs <= size then
    [ xs ]
  else
    let
      { before, after } = Array.splitAt size xs
    in
      Array.cons before (chunk size after)

processChunk
  :: ∀ @p name opsEffSym opsEff copyOnWriteStateEffSym copyOnWritePersistEffSym fx
   . IsProjection p name opsEffSym opsEff _ _ _ _
  => IsSymbol name
  => IsSymbol opsEffSym
  => IsSymbol copyOnWriteStateEffSym
  => IsSymbol copyOnWritePersistEffSym
  => Append name "ProjectionWriteCopyState" copyOnWriteStateEffSym
  => Append name "ProjectionWriteCopyPersist" copyOnWritePersistEffSym
  => Row.Union opsEff _ (READER_POSTGRES_EDGE_CLIENT + READER_POSTGRES_STORE_CLIENT + EFFECT + AFF + fx)
  => Row.Cons copyOnWriteStateEffSym (Run.State CopyOnWrite) _ (READER_POSTGRES_EDGE_CLIENT + READER_POSTGRES_STORE_CLIENT + EFFECT + AFF + fx)
  => Row.Cons copyOnWritePersistEffSym ProjectionPersist _ (READER_POSTGRES_EDGE_CLIENT + READER_POSTGRES_STORE_CLIENT + EFFECT + AFF + fx)
  => Array LoadedEvent
  -> Run (READER_POSTGRES_EDGE_CLIENT + READER_POSTGRES_STORE_CLIENT + EFFECT + AFF + fx) Ɩ
processChunk events = do
  traverse_ (play @p) events
  didModify <- persist @p

  case Array.last events of
    Just { sequenceNumber } -> updateCheckpoint (projectionSchemaName @name) sequenceNumber didModify
    _ -> ηι

getCheckpoint :: ∀ fx. String -> Run (READER_POSTGRES_EDGE_CLIENT + EFFECT + AFF + fx) String
getCheckpoint name = do
  let schema = caseToSnake name
  ensureProjectionsTable schema

  let sql = "SELECT checkpoint::varchar FROM \"" <> schema <> "\"._meta WHERE singleton = TRUE"

  rows <- Postgres.queryEdge sql []

  case rows of
    [ row ] ->
      case Control.Monad.Except.runExcept (readImpl row) of
        Right (obj :: { checkpoint :: String }) -> η obj.checkpoint
        Left _ -> η "0"
    _ -> do
      let insertSql = "INSERT INTO \"" <> schema <> "\"._meta (checkpoint, state) VALUES (0, $1) ON CONFLICT (singleton) DO NOTHING"
      ø $ Postgres.queryEdge insertSql [ writeImpl Running ]
      η "0"

updateCheckpoint :: ∀ fx. String -> String -> Boolean -> Run (READER_POSTGRES_EDGE_CLIENT + EFFECT + AFF + fx) Ɩ
updateCheckpoint name checkpoint didModify = do
  -- Note: We intentionally DO NOT call `ensureProjectionsTable` here.
  -- This function is called in a tight loop during event replay (once per batch).
  -- Calling DDL like `CREATE TABLE IF NOT EXISTS` heavily spams the Postgres 
  -- system catalogs, causing `tuple concurrently updated` errors under high parallelism.
  -- The table existence is already guaranteed because `getCheckpoint` always runs before.
  -- If the table is dropped mid-flight, the query will fail and crash the container,
  -- which is exactly the desired fail-fast behavior (e.g. relying on Docker restart policies).

  let
    schema = caseToSnake name
    sql =
      if didModify then
        "UPDATE \"" <> schema <> "\"._meta SET checkpoint = $1, updated_at = (NOW() AT TIME ZONE 'UTC'), updated_model_at = (NOW() AT TIME ZONE 'UTC') WHERE singleton = TRUE"
      else
        "UPDATE \"" <> schema <> "\"._meta SET checkpoint = $1, updated_at = (NOW() AT TIME ZONE 'UTC') WHERE singleton = TRUE"

  ø $ Postgres.queryEdge sql [ Foreign.unsafeToForeign checkpoint ]

  when didModify do
    let sql2 = "SELECT EXTRACT(EPOCH FROM created_at)::varchar AS created_at, EXTRACT(EPOCH FROM updated_model_at)::varchar AS updated_model_at FROM \"" <> schema <> "\"._meta WHERE singleton = TRUE"
    rows <- Postgres.queryEdge sql2 []
    case rows of
      [ row ] ->
        case Control.Monad.Except.runExcept (readImpl row) of
          Right (obj :: { created_at :: String, updated_model_at :: String }) -> do
            let newHash = obj.created_at <> "@" <> obj.updated_model_at
            writeModelHashCacheMirror schema Nothing newHash
          Left _ -> ηι
      _ -> ηι

setProjectionState :: ∀ fx. String -> State -> Run (READER_POSTGRES_EDGE_CLIENT + EFFECT + AFF + fx) Ɩ
setProjectionState name state = do
  let schema = caseToSnake name
  ensureProjectionsTable schema

  let sql = "UPDATE \"" <> schema <> "\"._meta SET state = $1, updated_at = (NOW() AT TIME ZONE 'UTC') WHERE singleton = TRUE"

  ø $ Postgres.queryEdge sql [ writeImpl state ]

foreign import _tryAdvisoryLock :: String -> Int -> String -> String -> String -> String -> Effect (Promise Boolean)

-- | Attempts to acquire an exclusive session-level advisory lock using a DEDICATED connection.
-- | 
-- | WHY A DEDICATED FFI CLIENT INSTEAD OF `Postgres.queryEdge`?
-- | `Postgres.queryEdge` borrows a connection from `pg-pool`, executes the query, and instantly 
-- | returns the connection to the pool. The lock is tied to the TCP session, not the Node.js process. 
-- | If `pg-pool` drops the connection later (e.g. `idleTimeoutMillis` or a syntax error), 
-- | Postgres silently drops the lock. The Projector loop (`goLoop`) would remain completely unaware, 
-- | leading to multiple Projectors concurrently acting as leader and processing events twice.
-- | Bypassing the pool and using a dedicated `pg.Client` forces the OS process to safely crash
-- | (via socket listeners) if the lock's TCP link ever dies, guaranteeing fail-fast orchestration.
tryAdvisoryLock :: ∀ fx. String -> Run (READER_POSTGRES_EDGE_CLIENT + EFFECT + AFF + fx) Boolean
tryAdvisoryLock name = do
  dbConfig <- askEdgeConfig
  let
    { directHost, port, database, user, password } = dbConfig
    host = directHost
  ʌ' $ toAffE $ _tryAdvisoryLock host port database user password name

data State = Running | Idle

derive instance Generic State _

instance ToString State where
  toString Running = "running"
  toString Idle = "idle"

instance WriteForeign State where
  writeImpl = genericWriteImplWithDefaultOpt

instance ReadForeign State where
  readImpl = genericReadImplWithDefaultOpt

ensureProjectionsTable :: ∀ fx. String -> Run (READER_POSTGRES_EDGE_CLIENT + EFFECT + AFF + fx) Ɩ
ensureProjectionsTable name = do
  let
    schema = caseToSnake name
    sqlTemplate =
      """
      CREATE SCHEMA IF NOT EXISTS "${schema}";
      CREATE TABLE IF NOT EXISTS "${schema}"._meta (
        singleton BOOLEAN PRIMARY KEY DEFAULT TRUE CHECK (singleton),
        checkpoint BIGINT NOT NULL,
        state VARCHAR NOT NULL,
        created_at TIMESTAMP NOT NULL DEFAULT (NOW() AT TIME ZONE 'UTC'),
        updated_at TIMESTAMP NOT NULL DEFAULT (NOW() AT TIME ZONE 'UTC'),
        updated_model_at TIMESTAMP NOT NULL DEFAULT (NOW() AT TIME ZONE 'UTC')
      );
      """
    sql = replaceAll (Pattern "${schema}") (Replacement schema) sqlTemplate

  ø $ Postgres.queryEdge sql []

getReadModelHash_ :: ∀ fx. String -> Maybe Key -> Run (READER_POSTGRES_EDGE_CLIENT + EFFECT + AFF + fx) String
getReadModelHash_ name mKey = do
  let schema = caseToSnake name

  mCachedHash <- readModelHashCacheMirror schema mKey

  case mCachedHash of
    Just cachedHash -> η cachedHash
    Nothing -> do
      case mKey of
        Nothing -> do
          ensureProjectionsTable schema

          let sql = "SELECT EXTRACT(EPOCH FROM created_at)::varchar AS created_at, EXTRACT(EPOCH FROM updated_model_at)::varchar AS updated_model_at FROM \"" <> schema <> "\"._meta WHERE singleton = TRUE"

          rows <- Postgres.queryEdge sql []

          case rows of
            [ row ] ->
              case Control.Monad.Except.runExcept (readImpl row) of
                Right (obj :: { created_at :: String, updated_model_at :: String }) -> do
                  let newHash = obj.created_at <> "@" <> obj.updated_model_at
                  writeModelHashCacheMirror schema Nothing newHash
                  η newHash
                Left _ -> η "0@0"
            _ -> η "0@0"
        Just _ -> η "0@0"

readModelHashCacheMirror :: ∀ fx. String -> Maybe Key -> Run (EFFECT + AFF + fx) (Maybe String)
readModelHashCacheMirror schema mKey = do
  case mKey of
    Just key -> do
      let
        innerKey = unwrap key
        searchKeys = (Array.catMaybes [ innerKey.primary ]) <> innerKey.aliases
        plural = caseToSnake innerKey.pluralType

      let
        tryRead :: Array String -> Run (EFFECT + AFF + fx) (Maybe String)
        tryRead [] = η Nothing
        tryRead ks = do
          let k = Array.head ks ??⇒ ""
          let rest = Array.drop 1 ks
          res <- ʌ' $ attempt $ FS.readTextFile UTF8 (cacheDir <> "/" <> schema <> "_" <> plural <> "_" <> k <> "_hash.json")
          case res of
            Right s -> case readJSON s of
              Right json -> case Control.Monad.Except.runExcept (readImpl json) of
                Right (obj :: { hash :: String }) -> η $ Just obj.hash
                Left _ -> tryRead rest
              Left _ -> tryRead rest
            Left _ -> tryRead rest

      tryRead searchKeys

    Nothing -> do
      res <- ʌ' $ attempt $ FS.readTextFile UTF8 (cacheDir <> "/" <> schema <> "_hash.json")
      case res of
        Right s -> case readJSON s of
          Right json -> case Control.Monad.Except.runExcept (readImpl json) of
            Right (obj :: { hash :: String }) -> η $ Just obj.hash
            Left _ -> η Nothing
          Left _ -> η Nothing
        Left _ -> η Nothing

-- | Writes the model hash to a cache mirror (file + short ttl mem).
-- | This is used to avoid querying the database for the model hash on every cache invalidation.
writeModelHashCacheMirror :: ∀ fx. String -> Maybe Key -> String -> Run (EFFECT + AFF + fx) Ɩ
writeModelHashCacheMirror schema mKey hash = do
  let content = writeJSON $ writeImpl { hash }
  case mKey of
    Just key -> do
      let
        innerKey = unwrap key
        searchKeys = (Array.catMaybes [ innerKey.primary ]) <> innerKey.aliases
        plural = caseToSnake innerKey.pluralType

      searchKeys # traverse_ \k -> do
        ø $ ʌ' $ attempt $ FS.writeTextFile UTF8 (cacheDir <> "/" <> schema <> "_" <> plural <> "_" <> k <> "_hash.json") content
    Nothing -> do
      ø $ ʌ' $ attempt $ FS.writeTextFile UTF8 (cacheDir <> "/" <> schema <> "_hash.json") content
