module Infra.Queue.RabbitMq.Queue
  ( interpretQueue
  , queueCommand
  ) where

import Proem

import Core.Message.Command.Index (Command)
import Core.Message.Queue (QUEUE, Queue(..), EventToProcess)
import Infra.Client.RabbitMq.RabbitMq (READER_RABBIT_MQ_CLIENT, readerRabbitMqClient')
import Infra.Client.RabbitMq.RabbitMq as RabbitMq
import Core.Mod.Trace.Trace (READER_TRACE, Trace)
import Yoga.JSON (writeJSON)
import Run (AFF, EFFECT, Run, on, send)
import Run as Run
import Run.Reader (askAt)
import Util.Lexicon.Queue (queue')
import Type.Row (type (+))

queueCommand
  :: ∀ fx
   . Trace
  -> Command
  -> Run (READER_RABBIT_MQ_CLIENT + EFFECT + AFF + fx) Ɩ
queueCommand trace cmd = do
  { config } <- askAt readerRabbitMqClient'

  RabbitMq.sendToQueueWithAssert config.queue.command.logic $ writeJSON { payload: cmd, trace }

queueEvent
  :: ∀ fx
   . Trace
  -> EventToProcess
  -> Run (READER_RABBIT_MQ_CLIENT + EFFECT + AFF + fx) Ɩ
queueEvent trace event = do
  { config } <- askAt readerRabbitMqClient'

  RabbitMq.sendToQueueWithAssert config.queue.event.logic $ writeJSON { payload: event, trace }

interpretQueue
  :: ∀ fx a
   . Run (QUEUE + READER_RABBIT_MQ_CLIENT + READER_TRACE + EFFECT + AFF + fx) a
  -> Run (READER_RABBIT_MQ_CLIENT + READER_TRACE + EFFECT + AFF + fx) a
interpretQueue = Run.interpret (on queue' handle send)
  where
  handle :: ∀ a'. Queue a' -> Run (READER_RABBIT_MQ_CLIENT + READER_TRACE + EFFECT + AFF + fx) a'
  handle (QueueCommand trace command next) = do
    queueCommand trace command
    η $ next
  handle (QueueEvent trace event next) = do
    queueEvent trace event
    η $ next