module Core.Feat.Review.Message.Command.CorrectArticle.Command
  ( CorrectArticle(..)
  , CorrectArticleAliasRow
  ) where

import Core.Message.Command.Command (class IsCommand, class IsProtectedAgainstConcurrency, defaultMaxConcurrencyRetries, ConcurrencyPriority(..), defaultCheckLoadedEvents, defaultHandle)
import Core.Feat.Review.Message.Command.CorrectArticle.Decide (decide)
import Core.Feat.Review.Message.Command.CorrectArticle.Filter (filter)
import Core.Feat.Review.Message.Command.CorrectArticle.Payload (Payload, Fields)
import Core.Feat.Review.Message.Command.CorrectArticle.Play (play)
import Core.Feat.Review.Message.Command.CorrectArticle.Result (Result, toResult)
import Core.Feat.Review.Message.Command.CorrectArticle.State (State, initialState)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Generic.Rep (class Generic)
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)
import Util.Type.Random (class Random)
import Util.Type.Type (class Reflect, reflectConstructorName)

newtype CorrectArticle = CorrectArticle Payload

derive instance Newtype CorrectArticle _
derive instance Generic CorrectArticle _
derive newtype instance Random CorrectArticle
derive newtype instance WriteForeign CorrectArticle
derive newtype instance ReadForeign CorrectArticle

instance Reflect CorrectArticle where
  reflectName = reflectConstructorName @CorrectArticle

instance IsProtectedAgainstConcurrency CorrectArticle where
  priority = Safe
  maxRetries = defaultMaxConcurrencyRetries
  baseRetryDelayMs = 100

instance
  IsCommand
    CorrectArticle
    State
    Fields
    Payload
    Result
  where
  description = "Correct an article"

  handle payload = do
    defaultHandle @CorrectArticle (Just filter) defaultCheckLoadedEvents initialState play decide toResult payload

type CorrectArticleAliasRow r =
  ( "CorrectAnArticle" :: CorrectArticle
  , "CorrigeArticle" :: CorrectArticle
  , "CorrigerArticle" :: CorrectArticle
  , "CorrectionArticle" :: CorrectArticle
  | r
  )
