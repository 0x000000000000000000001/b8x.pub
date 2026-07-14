module Core.Feat.Review.Message.Command.AddArticleToNewsRelatedWhitelist.Command
  ( AddArticleToNewsRelatedWhitelist(..)
  ) where

import Proem

import Core.Message.Command.Command (class IsCommand, class IsProtectedAgainstConcurrency, defaultMaxConcurrencyRetries, ConcurrencyPriority(..), defaultCheckLoadedEvents, defaultHandle)
import Core.Feat.Review.Message.Command.AddArticleToNewsRelatedWhitelist.Decide (decide)
import Core.Feat.Review.Message.Command.AddArticleToNewsRelatedWhitelist.Filter (filter)
import Core.Feat.Review.Message.Command.AddArticleToNewsRelatedWhitelist.Payload (Payload, Fields)
import Core.Feat.Review.Message.Command.AddArticleToNewsRelatedWhitelist.Play (play)
import Core.Feat.Review.Message.Command.AddArticleToNewsRelatedWhitelist.Result (Result, toResult)
import Core.Feat.Review.Message.Command.AddArticleToNewsRelatedWhitelist.State (State, initialState)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Generic.Rep (class Generic)
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)
import Util.Type.Random (class Random)
import Util.Type.Type (class Reflect, reflectConstructorName)
import Core.Feat.Review.Message.Query.VerifyNewsRelatedArticleWhitelistLimit.VerifyNewsRelatedArticleWhitelistLimit (verifyNewsRelatedArticleWhitelistLimit)

newtype AddArticleToNewsRelatedWhitelist = AddArticleToNewsRelatedWhitelist Payload

derive instance Newtype AddArticleToNewsRelatedWhitelist _
derive instance Generic AddArticleToNewsRelatedWhitelist _
derive newtype instance Random AddArticleToNewsRelatedWhitelist
derive newtype instance WriteForeign AddArticleToNewsRelatedWhitelist
derive newtype instance ReadForeign AddArticleToNewsRelatedWhitelist

instance Reflect AddArticleToNewsRelatedWhitelist where
  reflectName = reflectConstructorName @AddArticleToNewsRelatedWhitelist

instance IsProtectedAgainstConcurrency AddArticleToNewsRelatedWhitelist where
  priority = Safe
  maxRetries = defaultMaxConcurrencyRetries
  baseRetryDelayMs = 100

instance
  IsCommand
    AddArticleToNewsRelatedWhitelist
    State
    Fields
    Payload
    Result
  where
  description = "Add an article to the news related whitelist"

  handle payload = do
    _ <- verifyNewsRelatedArticleWhitelistLimit {}

    defaultHandle @AddArticleToNewsRelatedWhitelist (Just filter) defaultCheckLoadedEvents initialState play decide toResult payload

  