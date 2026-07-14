module Core.Feat.Review.Message.Command.AddNewsTopic.Command
  ( AddNewsTopic(..)
  ) where

import Proem

import Core.Message.Command.Command (class IsCommand, class IsProtectedAgainstConcurrency, defaultMaxConcurrencyRetries, ConcurrencyPriority(..), defaultCheckLoadedEvents, defaultHandle)
import Core.Feat.Review.Message.Command.AddNewsTopic.Decide (decide)
import Core.Feat.Review.Message.Command.AddNewsTopic.Filter (filter)
import Core.Feat.Review.Message.Command.AddNewsTopic.Payload (Payload, Fields)
import Core.Feat.Review.Message.Command.AddNewsTopic.Play (play)
import Core.Feat.Review.Message.Command.AddNewsTopic.Result (Result, toResult)
import Core.Feat.Review.Message.Command.AddNewsTopic.State (State, initialState)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Generic.Rep (class Generic)
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)
import Util.Type.Random (class Random)
import Util.Type.Type (class Reflect, reflectConstructorName)
import Core.Feat.Review.Message.Query.VerifyNewsTopicLimit.VerifyNewsTopicLimit (verifyNewsTopicLimit)

newtype AddNewsTopic = AddNewsTopic Payload

derive instance Newtype AddNewsTopic _
derive instance Generic AddNewsTopic _
derive newtype instance Random AddNewsTopic
derive newtype instance WriteForeign AddNewsTopic
derive newtype instance ReadForeign AddNewsTopic

instance Reflect AddNewsTopic where
  reflectName = reflectConstructorName @AddNewsTopic

instance IsProtectedAgainstConcurrency AddNewsTopic where
  priority = Safe
  maxRetries = defaultMaxConcurrencyRetries
  baseRetryDelayMs = 100

instance
  IsCommand
    AddNewsTopic
    State
    Fields
    Payload
    Result
  where
  description = "Add a news topic"

  handle payload = do
    _ <- verifyNewsTopicLimit {}

    defaultHandle @AddNewsTopic (Just filter) defaultCheckLoadedEvents initialState play decide toResult payload

  