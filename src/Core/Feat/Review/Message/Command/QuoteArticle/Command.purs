module Core.Feat.Review.Message.Command.QuoteArticle.Command
  (QuoteArticle(..)
  ) where

import Core.Message.Command.Command (class IsCommand, class IsProtectedAgainstConcurrency, defaultMaxConcurrencyRetries, ConcurrencyPriority(..), defaultCheckLoadedEvents, defaultHandle)
import Core.Feat.Review.Message.Command.QuoteArticle.Decide (decide)
import Core.Feat.Review.Message.Command.QuoteArticle.Filter (filter)
import Core.Feat.Review.Message.Command.QuoteArticle.Payload (Payload, Fields)
import Core.Feat.Review.Message.Command.QuoteArticle.Play (play)
import Core.Feat.Review.Message.Command.QuoteArticle.Result (Result, toResult)
import Core.Feat.Review.Message.Command.QuoteArticle.State (State, initialState)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Generic.Rep (class Generic)
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)
import Util.Type.Random (class Random)
import Util.Type.Type (class Reflect, reflectConstructorName)

newtype QuoteArticle = QuoteArticle Payload

derive instance Newtype QuoteArticle _
derive instance Generic QuoteArticle _
derive newtype instance Random QuoteArticle
derive newtype instance WriteForeign QuoteArticle
derive newtype instance ReadForeign QuoteArticle

instance Reflect QuoteArticle where
  reflectName = reflectConstructorName @QuoteArticle

instance IsProtectedAgainstConcurrency QuoteArticle where
  priority = Safe
  maxRetries = defaultMaxConcurrencyRetries
  baseRetryDelayMs = 100

instance
  IsCommand
    QuoteArticle
    State
    Fields
    Payload
    Result
  where
  description = "Quote an article"

  handle = defaultHandle @QuoteArticle (Just filter) defaultCheckLoadedEvents initialState play decide toResult

  