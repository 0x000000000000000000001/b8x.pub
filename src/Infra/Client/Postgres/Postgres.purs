module Infra.Client.Postgres.Postgres
  ( Client
  , Connection
  , ConnectionPool
  , Tx
  , NoTx
  , Handle
  , ConnectionPoolHandle
  , NoTxConnectionHandle
  , TxConnectionHandle
  , READER_POSTGRES_STORE_CLIENT
  , READER_POSTGRES_EDGE_CLIENT
  , READER_POSTGRES_STORE_LOCK_CLIENT
  , askStoreConfig
  , askEdgeConfig
  , askStoreLockConfig
  , askStoreConnectionPoolHandle
  , askEdgeConnectionPoolHandle
  , askStoreLockConnectionPoolHandle
  , closeClient
  , closeHandle
  , createClient
  , createConnectionPoolHandle
  , createLazyClient
  , escapeIdentifier
  , queryStore
  , queryEdge
  , queryStoreLock
  , tryQueryStore
  , tryQueryEdge
  , tryQueryStoreLock
  , queryCountStore
  , queryCountEdge
  , queryCountStoreLock
  , queryCount_
  , query_
  , query
  , tryQuery
  , readerPostgresStoreClient'
  , readerPostgresEdgeClient'
  , readerPostgresStoreLockClient'
  , runPostgresStoreClientReader
  , runPostgresEdgeClientReader
  , runPostgresStoreLockClientReader
  , askStoreNoTxConnectionHandle
  , askStoreLockNoTxConnectionHandle
  , withStoreTxConnectionHandle
  , withStoreLockNoTxConnectionHandle
  , release
  ) where

import Proem

import Config.InternalConfig (DbSubConfig)
import Foreign (Foreign)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Aff (attempt)
import Effect.Aff.Class (class MonadAff)
import Effect.Exception (Error)
import Effect.Ref (Ref)
import Effect.Ref as Ref
import Promise as Promise
import Promise.Aff (toAffE)
import Run (Run, AFF, EFFECT)
import Run.Reader (Reader, askAt, runReaderAt)
import Type.Row (type (+))
import Unsafe.Coerce (unsafeCoerce)

data Connection
data ConnectionPool

data Tx
data NoTx

foreign import data Handle :: Type -> Type -> Type

type ConnectionPoolHandle = Handle ConnectionPool NoTx
type NoTxConnectionHandle = Handle Connection NoTx
type TxConnectionHandle = Handle Connection Tx

type Client =
  { handleRef :: Ref (Maybe ConnectionPoolHandle)
  , config :: DbSubConfig
  }

type READER_POSTGRES_STORE_CLIENT fx = (readerPostgresStoreClient :: Reader Client | fx)
type READER_POSTGRES_EDGE_CLIENT fx = (readerPostgresEdgeClient :: Reader Client | fx)
type READER_POSTGRES_STORE_LOCK_CLIENT fx = (readerPostgresStoreLockClient :: Reader Client | fx)

readerPostgresStoreClient' = π :: Π "readerPostgresStoreClient"
readerPostgresEdgeClient' = π :: Π "readerPostgresEdgeClient"
readerPostgresStoreLockClient' = π :: Π "readerPostgresStoreLockClient"

runPostgresStoreClientReader :: ∀ fx a. Client -> Run (READER_POSTGRES_STORE_CLIENT + fx) a -> Run fx a
runPostgresStoreClientReader = runReaderAt readerPostgresStoreClient'

runPostgresEdgeClientReader :: ∀ fx a. Client -> Run (READER_POSTGRES_EDGE_CLIENT + fx) a -> Run fx a
runPostgresEdgeClientReader = runReaderAt readerPostgresEdgeClient'

runPostgresStoreLockClientReader :: ∀ fx a. Client -> Run (READER_POSTGRES_STORE_LOCK_CLIENT + fx) a -> Run fx a
runPostgresStoreLockClientReader = runReaderAt readerPostgresStoreLockClient'

createLazyClient :: ∀ m. MonadAff m => DbSubConfig -> m Client
createLazyClient config = do
  handleRef <- ʌ $ Ref.new Nothing
  η { handleRef, config }

createClient :: ∀ m. MonadAff m => DbSubConfig -> m Client
createClient config = do
  handle <- createConnectionPoolHandle config
  handleRef <- ʌ $ Ref.new (Just handle)
  η { handleRef, config }

foreign import _createConnectionPoolHandle :: String -> Int -> String -> String -> String -> Int -> Effect ConnectionPoolHandle

createConnectionPoolHandle :: ∀ m. MonadAff m => DbSubConfig -> m ConnectionPoolHandle
createConnectionPoolHandle { host, port, database, user, password, idleTimeoutMs } = ʌ $ _createConnectionPoolHandle host port database user password idleTimeoutMs

foreign import _closeHandle :: ∀ s t. Handle s t -> Effect Ɩ

closeHandle :: ∀ m s t. MonadAff m => Handle s t -> m Ɩ
closeHandle handle = ʌ' $ toAffE $ Promise.resolve <$> _closeHandle handle

closeClient :: ∀ m. MonadAff m => Client -> m Ɩ
closeClient { handleRef } = do
  maybeHandle <- ʌ $ Ref.read handleRef
  case maybeHandle of
    Just handle -> closeHandle handle
    Nothing -> η ι

foreign import _query :: ∀ s t. Handle s t -> String -> Array Foreign -> Effect (Array Foreign)

query_ :: ∀ m s t. MonadAff m => Handle s t -> String -> Array Foreign -> m (Array Foreign)
query_ postgresClient q p = ʌ' $ toAffE $ Promise.resolve <$> _query postgresClient q p

query :: ∀ t fx. Handle Connection t -> String -> Array Foreign -> Run (AFF + EFFECT + fx) (Array Foreign)
query tx q p = ʌ' $ toAffE $ Promise.resolve <$> _query tx q p

tryQuery :: ∀ t fx. Handle Connection t -> String -> Array Foreign -> Run (AFF + EFFECT + fx) (Either Error (Array Foreign))
tryQuery tx q p = ʌ' $ attempt $ toAffE $ Promise.resolve <$> _query tx q p

queryStore :: ∀ fx. String -> Array Foreign -> Run (AFF + EFFECT + READER_POSTGRES_STORE_CLIENT + fx) (Array Foreign)
queryStore q p = do
  handle <- askStoreConnectionPoolHandle
  query_ handle q p

queryEdge :: ∀ fx. String -> Array Foreign -> Run (AFF + EFFECT + READER_POSTGRES_EDGE_CLIENT + fx) (Array Foreign)
queryEdge q p = do
  handle <- askEdgeConnectionPoolHandle
  query_ handle q p

queryStoreLock :: ∀ fx. String -> Array Foreign -> Run (AFF + EFFECT + READER_POSTGRES_STORE_LOCK_CLIENT + fx) (Array Foreign)
queryStoreLock q p = do
  handle <- askStoreLockConnectionPoolHandle
  query_ handle q p

tryQueryStore :: ∀ fx. String -> Array Foreign -> Run (AFF + EFFECT + READER_POSTGRES_STORE_CLIENT + fx) (Either Error (Array Foreign))
tryQueryStore q p = do
  handle <- askStoreConnectionPoolHandle
  ʌ' $ attempt $ query_ handle q p

tryQueryEdge :: ∀ fx. String -> Array Foreign -> Run (AFF + EFFECT + READER_POSTGRES_EDGE_CLIENT + fx) (Either Error (Array Foreign))
tryQueryEdge q p = do
  handle <- askEdgeConnectionPoolHandle
  ʌ' $ attempt $ query_ handle q p

tryQueryStoreLock :: ∀ fx. String -> Array Foreign -> Run (AFF + EFFECT + READER_POSTGRES_STORE_LOCK_CLIENT + fx) (Either Error (Array Foreign))
tryQueryStoreLock q p = do
  handle <- askStoreLockConnectionPoolHandle
  ʌ' $ attempt $ query_ handle q p

foreign import _queryCount :: ∀ s t. Handle s t -> String -> Array Foreign -> Effect Int

queryCount_ :: ∀ m s t. MonadAff m => Handle s t -> String -> Array Foreign -> m Int
queryCount_ postgresClient q p = ʌ' $ toAffE $ Promise.resolve <$> _queryCount postgresClient q p

queryCountStore :: ∀ fx. String -> Array Foreign -> Run (AFF + EFFECT + READER_POSTGRES_STORE_CLIENT + fx) Int
queryCountStore q p = do
  handle <- askStoreConnectionPoolHandle
  queryCount_ handle q p

queryCountEdge :: ∀ fx. String -> Array Foreign -> Run (AFF + EFFECT + READER_POSTGRES_EDGE_CLIENT + fx) Int
queryCountEdge q p = do
  handle <- askEdgeConnectionPoolHandle
  queryCount_ handle q p

queryCountStoreLock :: ∀ fx. String -> Array Foreign -> Run (AFF + EFFECT + READER_POSTGRES_STORE_LOCK_CLIENT + fx) Int
queryCountStoreLock q p = do
  handle <- askStoreLockConnectionPoolHandle
  queryCount_ handle q p

ensureStoreHandle :: ∀ fx. Client -> Run (READER_POSTGRES_STORE_CLIENT + EFFECT + AFF + fx) ConnectionPoolHandle
ensureStoreHandle { handleRef, config } = do
  maybeHandle <- ʌ $ Ref.read handleRef
  case maybeHandle of
    Just handle -> η handle
    Nothing -> do
      handle <- createConnectionPoolHandle config
      ʌ $ Ref.write (Just handle) handleRef
      η handle

ensureEdgeHandle :: ∀ fx. Client -> Run (READER_POSTGRES_EDGE_CLIENT + EFFECT + AFF + fx) ConnectionPoolHandle
ensureEdgeHandle { handleRef, config } = do
  maybeHandle <- ʌ $ Ref.read handleRef
  case maybeHandle of
    Just handle -> η handle
    Nothing -> do
      handle <- createConnectionPoolHandle config
      ʌ $ Ref.write (Just handle) handleRef
      η handle

ensureStoreLockHandle :: ∀ fx. Client -> Run (READER_POSTGRES_STORE_LOCK_CLIENT + EFFECT + AFF + fx) ConnectionPoolHandle
ensureStoreLockHandle { handleRef, config } = do
  maybeHandle <- ʌ $ Ref.read handleRef
  case maybeHandle of
    Just handle -> η handle
    Nothing -> do
      handle <- createConnectionPoolHandle config
      ʌ $ Ref.write (Just handle) handleRef
      η handle

askStoreClient :: ∀ fx. Run (READER_POSTGRES_STORE_CLIENT + EFFECT + AFF + fx) Client
askStoreClient = askAt readerPostgresStoreClient'

askEdgeClient :: ∀ fx. Run (READER_POSTGRES_EDGE_CLIENT + EFFECT + AFF + fx) Client
askEdgeClient = askAt readerPostgresEdgeClient'

askStoreLockClient :: ∀ fx. Run (READER_POSTGRES_STORE_LOCK_CLIENT + EFFECT + AFF + fx) Client
askStoreLockClient = askAt readerPostgresStoreLockClient'

askStoreConnectionPoolHandle :: ∀ fx. Run (READER_POSTGRES_STORE_CLIENT + EFFECT + AFF + fx) ConnectionPoolHandle
askStoreConnectionPoolHandle = ensureStoreHandle =<< askStoreClient

askEdgeConnectionPoolHandle :: ∀ fx. Run (READER_POSTGRES_EDGE_CLIENT + EFFECT + AFF + fx) ConnectionPoolHandle
askEdgeConnectionPoolHandle = ensureEdgeHandle =<< askEdgeClient

askStoreLockConnectionPoolHandle :: ∀ fx. Run (READER_POSTGRES_STORE_LOCK_CLIENT + EFFECT + AFF + fx) ConnectionPoolHandle
askStoreLockConnectionPoolHandle = ensureStoreLockHandle =<< askStoreLockClient

askStoreConfig :: ∀ fx. Run (READER_POSTGRES_STORE_CLIENT + EFFECT + AFF + fx) DbSubConfig
askStoreConfig = askStoreClient <#> _.config

askEdgeConfig :: ∀ fx. Run (READER_POSTGRES_EDGE_CLIENT + EFFECT + AFF + fx) DbSubConfig
askEdgeConfig = askEdgeClient <#> _.config

askStoreLockConfig :: ∀ fx. Run (READER_POSTGRES_STORE_LOCK_CLIENT + EFFECT + AFF + fx) DbSubConfig
askStoreLockConfig = askStoreLockClient <#> _.config

foreign import _escapeIdentifier :: String -> String

escapeIdentifier :: String -> String
escapeIdentifier = _escapeIdentifier

foreign import _dedicate :: ConnectionPoolHandle -> Effect NoTxConnectionHandle
foreign import _release :: NoTxConnectionHandle -> Effect Ɩ

release :: ∀ fx. NoTxConnectionHandle -> Run (AFF + EFFECT + fx) Ɩ
release tx = ʌ' $ toAffE $ Promise.resolve <$> _release tx

askStoreNoTxConnectionHandle :: ∀ fx. Run (AFF + EFFECT + READER_POSTGRES_STORE_CLIENT + fx) NoTxConnectionHandle
askStoreNoTxConnectionHandle = do
  handle <- askStoreConnectionPoolHandle
  ʌ' $ toAffE $ Promise.resolve <$> _dedicate handle

askStoreLockNoTxConnectionHandle :: ∀ fx. Run (AFF + EFFECT + READER_POSTGRES_STORE_LOCK_CLIENT + fx) NoTxConnectionHandle
askStoreLockNoTxConnectionHandle = do
  handle <- askStoreLockConnectionPoolHandle
  ʌ' $ toAffE $ Promise.resolve <$> _dedicate handle

withStoreTxConnectionHandle :: ∀ a fx. (TxConnectionHandle -> Run (AFF + EFFECT + READER_POSTGRES_STORE_CLIENT + fx) (Either Error a)) -> Run (AFF + EFFECT + READER_POSTGRES_STORE_CLIENT + fx) (Either Error a)
withStoreTxConnectionHandle action = do
  handle <- askStoreNoTxConnectionHandle

  ø $ query handle "BEGIN" []

  res <- action (unsafeCoerce handle)

  case res of
    Left err -> do
      ø $ query handle "ROLLBACK" []

      release handle

      η (Left err)

    Right val -> do
      ø $ query handle "COMMIT" []

      release handle

      η (Right val)

withStoreLockNoTxConnectionHandle :: ∀ a fx. (NoTxConnectionHandle -> Run (AFF + EFFECT + READER_POSTGRES_STORE_LOCK_CLIENT + fx) (Either Error a)) -> Run (AFF + EFFECT + READER_POSTGRES_STORE_LOCK_CLIENT + fx) (Either Error a)
withStoreLockNoTxConnectionHandle action = do
  handle <- askStoreLockNoTxConnectionHandle

  res <- action handle

  ø $ tryQuery handle "SELECT pg_advisory_unlock_all()" [] -- Prevent lock leak

  release handle

  η res

