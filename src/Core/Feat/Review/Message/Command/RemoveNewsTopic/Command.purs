module Core.Feat.Review.Message.Command.RemoveNewsTopic.Command
  (RemoveNewsTopic(..)
  ) where

import Core.Message.Command.Command (class IsCommand, class IsProtectedAgainstConcurrency, defaultMaxConcurrencyRetries, ConcurrencyPriority(..), defaultCheckLoadedEvents, defaultHandle)
import Core.Feat.Review.Message.Command.RemoveNewsTopic.Decide (decide)
import Core.Feat.Review.Message.Command.RemoveNewsTopic.Filter (filter)
import Core.Feat.Review.Message.Command.RemoveNewsTopic.Payload (Payload, Fields)
import Core.Feat.Review.Message.Command.RemoveNewsTopic.Play (play)
import Core.Feat.Review.Message.Command.RemoveNewsTopic.Result (Result, toResult)
import Core.Feat.Review.Message.Command.RemoveNewsTopic.State (State, initialState)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Generic.Rep (class Generic)
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)
import Util.Type.Random (class Random)
import Util.Type.Type (class Reflect, reflectConstructorName)

newtype RemoveNewsTopic = RemoveNewsTopic Payload

derive instance Newtype RemoveNewsTopic _
derive instance Generic RemoveNewsTopic _
derive newtype instance Random RemoveNewsTopic
derive newtype instance WriteForeign RemoveNewsTopic
derive newtype instance ReadForeign RemoveNewsTopic

instance Reflect RemoveNewsTopic where
  reflectName = reflectConstructorName @RemoveNewsTopic

instance IsProtectedAgainstConcurrency RemoveNewsTopic where
  priority = Safe
  maxRetries = defaultMaxConcurrencyRetries
  baseRetryDelayMs = 100

instance
  IsCommand
    RemoveNewsTopic
    State
    Fields
    Payload
    Result
  where
  description = "Remove a news topic"

  handle = defaultHandle @RemoveNewsTopic (Just filter) defaultCheckLoadedEvents initialState play decide toResult

  