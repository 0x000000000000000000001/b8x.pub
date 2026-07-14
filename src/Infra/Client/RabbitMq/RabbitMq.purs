module Infra.Client.RabbitMq.RabbitMq
  (Channel
  , Client
  , Connection
  , Handles
  , READER_RABBIT_MQ_CLIENT
  , _assertQueue
  , _closeChannel
  , _closeConnection
  , _consume
  , _createChannel
  , _createConnection
  , _sendToQueue
  , askChannel
  , assertConsume
  , assertConsume_
  , assertQueue
  , assertQueue_
  , closeChannel
  , closeClient
  , closeConnection
  , consume
  , consume_
  , createChannel
  , createChannelWithConnection
  , createClient
  , createConnection
  , createSharedNoTxHandles
  , createLazyClient
  , ensureHandles
  , readerRabbitMqClient'
  , runRabbitMqClientReader
  , sendToQueue
  , sendToQueueWithAssert
  , sendToQueueWithAssert_
  , sendToQueue_
  ) where

import Proem

import Config.InternalConfig (MqConfig)
import Promise (Promise)
import Promise.Aff (toAffE)
import Promise.Internal as PromiseInternal
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Aff.Class (class MonadAff)
import Effect.Ref (Ref)
import Effect.Ref as Ref
import Run (AFF, EFFECT, Run)
import Run.Reader (Reader, askAt, runReaderAt)
import Type.Row (type (+))

foreign import data Connection :: Type
foreign import data Channel :: Type

type Handles =
  { connection :: Connection
  , channel :: Channel
  }

type Client =
  { handlesRef :: Ref (Maybe Handles)
  , config :: MqConfig
  }

type READER_RABBIT_MQ_CLIENT fx = (readerRabbitMqClient :: Reader Client | fx)

readerRabbitMqClient' = π :: Π "readerRabbitMqClient"

runRabbitMqClientReader :: ∀ fx a. Client -> Run (READER_RABBIT_MQ_CLIENT + fx) a -> Run fx a
runRabbitMqClientReader = runReaderAt readerRabbitMqClient'

createLazyClient :: ∀ m. MonadAff m => MqConfig -> m Client
createLazyClient config = do
  handlesRef <- ʌ $ Ref.new Nothing
  η { handlesRef, config }

createClient :: ∀ m. MonadAff m => MqConfig -> m Client
createClient config = do
  handles <- createSharedNoTxHandles config
  handlesRef <- ʌ $ Ref.new (Just handles)
  η { handlesRef, config }

createSharedNoTxHandles :: ∀ m. MonadAff m => MqConfig -> m Handles
createSharedNoTxHandles { host, port, user, password } = do
  connection <- createConnection host port user password
  channel <- createChannelWithConnection connection
  η { connection, channel }

foreign import _createConnectionImpl :: ∀ newFn. newFn -> String -> Int -> String -> String -> Effect (Promise Connection)

_createConnection :: String -> Int -> String -> String -> Effect (Promise Connection)
_createConnection = _createConnectionImpl PromiseInternal.new

createConnection :: ∀ m. MonadAff m => String -> Int -> String -> String -> m Connection
createConnection host port user password = ʌ' $ toAffE $ _createConnection host port user password

foreign import _createChannelImpl :: ∀ newFn. newFn -> Connection -> Effect (Promise Channel)

_createChannel :: Connection -> Effect (Promise Channel)
_createChannel = _createChannelImpl PromiseInternal.new

createChannelWithConnection :: ∀ m. MonadAff m => Connection -> m Channel
createChannelWithConnection conn = ʌ' $ toAffE $ _createChannel conn

createChannel :: ∀ m. MonadAff m => String -> Int -> String -> String -> m Channel
createChannel host port user password = do
  conn <- createConnection host port user password
  createChannelWithConnection conn

foreign import _assertQueueImpl :: ∀ newFn. newFn -> Channel -> String -> Effect (Promise Ɩ)

_assertQueue :: Channel -> String -> Effect (Promise Ɩ)
_assertQueue = _assertQueueImpl PromiseInternal.new

assertQueue_ :: ∀ m. MonadAff m => Channel -> String -> m Ɩ
assertQueue_ ch q = ʌ' $ toAffE $ _assertQueue ch q

assertQueue :: ∀ fx. String -> Run (READER_RABBIT_MQ_CLIENT + EFFECT + AFF + fx) Ɩ
assertQueue q = do
  channel <- askChannel
  assertQueue_ channel q

foreign import _sendToQueueImpl :: ∀ newFn. newFn -> Channel -> String -> String -> Effect (Promise Ɩ)

_sendToQueue :: Channel -> String -> String -> Effect (Promise Ɩ)
_sendToQueue = _sendToQueueImpl PromiseInternal.new

sendToQueue_ :: ∀ m. MonadAff m => Channel -> String -> String -> m Ɩ
sendToQueue_ ch q msg = ʌ' $ toAffE $ _sendToQueue ch q msg

sendToQueue :: ∀ fx. String -> String -> Run (READER_RABBIT_MQ_CLIENT + EFFECT + AFF + fx) Ɩ
sendToQueue q msg = do
  channel <- askChannel
  sendToQueue_ channel q msg

sendToQueueWithAssert_ :: ∀ m. MonadAff m => Channel -> String -> String -> m Ɩ
sendToQueueWithAssert_ ch q msg = do
  assertQueue_ ch q
  sendToQueue_ ch q msg

sendToQueueWithAssert :: ∀ fx. String -> String -> Run (READER_RABBIT_MQ_CLIENT + EFFECT + AFF + fx) Ɩ
sendToQueueWithAssert q msg = do
  channel <- askChannel
  sendToQueueWithAssert_ channel q msg

foreign import _consumeImpl :: ∀ newFn. newFn -> Channel -> String -> (String -> Effect Ɩ) -> Effect (Promise Ɩ)

_consume :: Channel -> String -> (String -> Effect Ɩ) -> Effect (Promise Ɩ)
_consume = _consumeImpl PromiseInternal.new

consume_ :: ∀ m. MonadAff m => Channel -> String -> (String -> Effect Ɩ) -> m Ɩ
consume_ ch q cb = ʌ' $ toAffE $ _consume ch q cb

consume :: ∀ fx. String -> (String -> Effect Ɩ) -> Run (READER_RABBIT_MQ_CLIENT + EFFECT + AFF + fx) Ɩ
consume q cb = do
  channel <- askChannel
  consume_ channel q cb

assertConsume_ :: ∀ m. MonadAff m => Channel -> String -> (String -> Effect Ɩ) -> m Ɩ
assertConsume_ ch q cb = do
  assertQueue_ ch q
  consume_ ch q cb

assertConsume :: ∀ fx. String -> (String -> Effect Ɩ) -> Run (READER_RABBIT_MQ_CLIENT + EFFECT + AFF + fx) Ɩ
assertConsume q cb = do
  channel <- askChannel
  assertConsume_ channel q cb

foreign import _closeConnectionImpl :: ∀ newFn. newFn -> Connection -> Effect (Promise Ɩ)

_closeConnection :: Connection -> Effect (Promise Ɩ)
_closeConnection = _closeConnectionImpl PromiseInternal.new

closeConnection :: ∀ m. MonadAff m => Connection -> m Ɩ
closeConnection conn = ʌ' $ toAffE $ _closeConnection conn

foreign import _closeChannelImpl :: ∀ newFn. newFn -> Channel -> Effect (Promise Ɩ)

_closeChannel :: Channel -> Effect (Promise Ɩ)
_closeChannel = _closeChannelImpl PromiseInternal.new

closeChannel :: ∀ m. MonadAff m => Channel -> m Ɩ
closeChannel ch = ʌ' $ toAffE $ _closeChannel ch

closeClient :: ∀ m. MonadAff m => Client -> m Ɩ
closeClient { handlesRef } = do
  maybeClient <- ʌ $ Ref.read handlesRef
  case maybeClient of
    Just { connection, channel } -> do
      closeChannel channel
      closeConnection connection
    Nothing -> η ι

ensureHandles :: ∀ fx. Client -> Run (READER_RABBIT_MQ_CLIENT + EFFECT + AFF + fx) Handles
ensureHandles { handlesRef, config } = do
  maybeClient <- ʌ $ Ref.read handlesRef
  case maybeClient of
    Just handles -> η handles
    Nothing -> do
      handles <- createSharedNoTxHandles config
      ʌ $ Ref.write (Just handles) handlesRef
      η handles

askClient :: ∀ fx. Run (READER_RABBIT_MQ_CLIENT + EFFECT + AFF + fx) Client
askClient = askAt readerRabbitMqClient'

askHandles :: ∀ fx. Run (READER_RABBIT_MQ_CLIENT + EFFECT + AFF + fx) Handles
askHandles = ensureHandles =<< askClient

askChannel :: ∀ fx. Run (READER_RABBIT_MQ_CLIENT + EFFECT + AFF + fx) Channel
askChannel = askHandles >>= (_.channel ▷ η)
