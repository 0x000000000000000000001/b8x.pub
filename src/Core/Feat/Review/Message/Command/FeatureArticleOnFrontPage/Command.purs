module Core.Feat.Review.Message.Command.FeatureArticleOnFrontPage.Command
  (FeatureArticleOnFrontPage(..)
  ) where

import Core.Message.Command.Command (class IsCommand, class IsProtectedAgainstConcurrency, defaultMaxConcurrencyRetries, ConcurrencyPriority(..), defaultCheckLoadedEvents, defaultHandle)
import Core.Feat.Review.Message.Command.FeatureArticleOnFrontPage.Decide (decide)
import Core.Feat.Review.Message.Command.FeatureArticleOnFrontPage.Payload (Payload, Fields)
import Core.Feat.Review.Message.Command.FeatureArticleOnFrontPage.Play (play)
import Core.Feat.Review.Message.Command.FeatureArticleOnFrontPage.Result (Result, toResult)
import Core.Feat.Review.Message.Command.FeatureArticleOnFrontPage.State (State, initialState)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Generic.Rep (class Generic)
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)
import Util.Type.Random (class Random)
import Util.Type.Type (class Reflect, reflectConstructorName)

newtype FeatureArticleOnFrontPage = FeatureArticleOnFrontPage Payload

derive instance Newtype FeatureArticleOnFrontPage _
derive instance Generic FeatureArticleOnFrontPage _
derive newtype instance Random FeatureArticleOnFrontPage
derive newtype instance WriteForeign FeatureArticleOnFrontPage
derive newtype instance ReadForeign FeatureArticleOnFrontPage

instance Reflect FeatureArticleOnFrontPage where
  reflectName = reflectConstructorName @FeatureArticleOnFrontPage

instance IsProtectedAgainstConcurrency FeatureArticleOnFrontPage where
  priority = Safe
  maxRetries = defaultMaxConcurrencyRetries
  baseRetryDelayMs = 100

instance
  IsCommand
    FeatureArticleOnFrontPage
    State
    Fields
    Payload
    Result
  where
  description = "Feature a article on the front page"

  handle = defaultHandle @FeatureArticleOnFrontPage Nothing defaultCheckLoadedEvents initialState play decide toResult

  