module Core.Feat.Review.Message.Command.DiscardArticle.Command
  (DiscardArticle(..)
  ) where

import Core.Message.Command.Command (class IsCommand, class IsProtectedAgainstConcurrency, defaultMaxConcurrencyRetries, ConcurrencyPriority(..), defaultCheckLoadedEvents, defaultHandle)
import Core.Feat.Review.Message.Command.DiscardArticle.Decide (decide)
import Core.Feat.Review.Message.Command.DiscardArticle.Filter (filter)
import Core.Feat.Review.Message.Command.DiscardArticle.Payload (Payload, Fields)
import Core.Feat.Review.Message.Command.DiscardArticle.Play (play)
import Core.Feat.Review.Message.Command.DiscardArticle.Result (Result, toResult)
import Core.Feat.Review.Message.Command.DiscardArticle.State (State, initialState)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Generic.Rep (class Generic)
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)
import Util.Type.Random (class Random)
import Util.Type.Type (class Reflect, reflectConstructorName)

newtype DiscardArticle = DiscardArticle Payload

derive instance Newtype DiscardArticle _
derive instance Generic DiscardArticle _
derive newtype instance Random DiscardArticle
derive newtype instance WriteForeign DiscardArticle
derive newtype instance ReadForeign DiscardArticle

instance Reflect DiscardArticle where
  reflectName = reflectConstructorName @DiscardArticle

instance IsProtectedAgainstConcurrency DiscardArticle where
  priority = Safe
  maxRetries = defaultMaxConcurrencyRetries
  baseRetryDelayMs = 100

instance
  IsCommand
    DiscardArticle
    State
    Fields
    Payload
    Result
  where
  description = "Discard an article"

  handle = defaultHandle @DiscardArticle (Just filter) defaultCheckLoadedEvents initialState play decide toResult

  