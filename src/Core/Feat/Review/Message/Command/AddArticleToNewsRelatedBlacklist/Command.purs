module Core.Feat.Review.Message.Command.AddArticleToNewsRelatedBlacklist.Command
  (AddArticleToNewsRelatedBlacklist(..)
  ) where

import Core.Message.Command.Command (class IsCommand, class IsProtectedAgainstConcurrency, defaultMaxConcurrencyRetries, ConcurrencyPriority(..), defaultCheckLoadedEvents, defaultHandle)
import Core.Feat.Review.Message.Command.AddArticleToNewsRelatedBlacklist.Decide (decide)
import Core.Feat.Review.Message.Command.AddArticleToNewsRelatedBlacklist.Filter (filter)
import Core.Feat.Review.Message.Command.AddArticleToNewsRelatedBlacklist.Payload (Payload, Fields)
import Core.Feat.Review.Message.Command.AddArticleToNewsRelatedBlacklist.Play (play)
import Core.Feat.Review.Message.Command.AddArticleToNewsRelatedBlacklist.Result (Result, toResult)
import Core.Feat.Review.Message.Command.AddArticleToNewsRelatedBlacklist.State (State, initialState)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Generic.Rep (class Generic)
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)
import Util.Type.Random (class Random)
import Util.Type.Type (class Reflect, reflectConstructorName)

newtype AddArticleToNewsRelatedBlacklist = AddArticleToNewsRelatedBlacklist Payload

derive instance Newtype AddArticleToNewsRelatedBlacklist _
derive instance Generic AddArticleToNewsRelatedBlacklist _
derive newtype instance Random AddArticleToNewsRelatedBlacklist
derive newtype instance WriteForeign AddArticleToNewsRelatedBlacklist
derive newtype instance ReadForeign AddArticleToNewsRelatedBlacklist

instance Reflect AddArticleToNewsRelatedBlacklist where
  reflectName = reflectConstructorName @AddArticleToNewsRelatedBlacklist

instance IsProtectedAgainstConcurrency AddArticleToNewsRelatedBlacklist where
  priority = Safe
  maxRetries = defaultMaxConcurrencyRetries
  baseRetryDelayMs = 100

instance
  IsCommand
    AddArticleToNewsRelatedBlacklist
    State
    Fields
    Payload
    Result
  where
  description = "Add an article to the news related blacklist"

  handle = defaultHandle @AddArticleToNewsRelatedBlacklist (Just filter) defaultCheckLoadedEvents initialState play decide toResult

  