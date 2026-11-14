module Infra.Client.RabbitMq.RabbitMq
  (Channel
  , Client
  , Connection
  , Handles
  , READER_RABBIT_MQ_CLIENT
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
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Aff.Class (class MonadAff)
import Effect.Aff.Compat (EffectFnAff, fromEffectFnAff)
import Effect.Uncurried (EffectFn1, mkEffectFn1)
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

foreign import _createConnectionImpl :: String -> Int -> String -> String -> EffectFnAff Connection

createConnection :: ∀ m. MonadAff m => String -> Int -> String -> String -> m Connection
createConnection host port user password = ʌ' $ fromEffectFnAff $ _createConnectionImpl host port user password

foreign import _createChannelImpl :: Connection -> EffectFnAff Channel

createChannelWithConnection :: ∀ m. MonadAff m => Connection -> m Channel
createChannelWithConnection conn = ʌ' $ fromEffectFnAff $ _createChannelImpl conn

createChannel :: ∀ m. MonadAff m => String -> Int -> String -> String -> m Channel
createChannel host port user password = do
  conn <- createConnection host port user password
  createChannelWithConnection conn

foreign import _assertQueueImpl :: Channel -> String -> EffectFnAff Ɩ

assertQueue_ :: ∀ m. MonadAff m => Channel -> String -> m Ɩ
assertQueue_ ch q = ʌ' $ fromEffectFnAff $ _assertQueueImpl ch q

assertQueue :: ∀ fx. String -> Run (READER_RABBIT_MQ_CLIENT + EFFECT + AFF + fx) Ɩ
assertQueue q = do
  channel <- askChannel
  assertQueue_ channel q

foreign import _sendToQueueImpl :: Channel -> String -> String -> EffectFnAff Ɩ

sendToQueue_ :: ∀ m. MonadAff m => Channel -> String -> String -> m Ɩ
sendToQueue_ ch q msg = ʌ' $ fromEffectFnAff $ _sendToQueueImpl ch q msg

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

foreign import _consumeImpl :: Channel -> String -> EffectFn1 String Ɩ -> EffectFnAff Ɩ

consume_ :: ∀ m. MonadAff m => Channel -> String -> (String -> Effect Ɩ) -> m Ɩ
consume_ ch q cb = ʌ' $ fromEffectFnAff $ _consumeImpl ch q (mkEffectFn1 cb)

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

foreign import _closeConnectionImpl :: Connection -> EffectFnAff Ɩ

closeConnection :: ∀ m. MonadAff m => Connection -> m Ɩ
closeConnection conn = ʌ' $ fromEffectFnAff $ _closeConnectionImpl conn

foreign import _closeChannelImpl :: Channel -> EffectFnAff Ɩ

closeChannel :: ∀ m. MonadAff m => Channel -> m Ɩ
closeChannel ch = ʌ' $ fromEffectFnAff $ _closeChannelImpl ch

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
