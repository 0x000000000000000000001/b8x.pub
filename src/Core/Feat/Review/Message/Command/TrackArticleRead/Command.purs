module Core.Feat.Review.Message.Command.TrackArticleRead.Command
  ( TrackArticleRead(..)
  ) where

import Core.Message.Command.Command (class IsCommand, class IsProtectedAgainstConcurrency, defaultMaxConcurrencyRetries, ConcurrencyPriority(..), defaultCheckLoadedEvents, defaultHandle)
import Core.Feat.Review.Message.Command.TrackArticleRead.Decide (decide)
import Core.Feat.Review.Message.Command.TrackArticleRead.Filter (filter)
import Core.Feat.Review.Message.Command.TrackArticleRead.Payload (Payload, Fields)
import Core.Feat.Review.Message.Command.TrackArticleRead.Play (play)
import Core.Feat.Review.Message.Command.TrackArticleRead.Result (Result, toResult)
import Core.Feat.Review.Message.Command.TrackArticleRead.State (State, initialState)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Generic.Rep (class Generic)
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)
import Util.Type.Random (class Random)
import Util.Type.Type (class Reflect, reflectConstructorName)

newtype TrackArticleRead = TrackArticleRead Payload

derive instance Newtype TrackArticleRead _
derive instance Generic TrackArticleRead _
derive newtype instance Random TrackArticleRead
derive newtype instance WriteForeign TrackArticleRead
derive newtype instance ReadForeign TrackArticleRead

instance Reflect TrackArticleRead where
  reflectName = reflectConstructorName @TrackArticleRead

instance IsProtectedAgainstConcurrency TrackArticleRead where
  priority = Fast
  maxRetries = defaultMaxConcurrencyRetries
  baseRetryDelayMs = 100

instance
  IsCommand
    TrackArticleRead
    State
    Fields
    Payload
    Result
  where
  description = "Track an article read"

  handle = defaultHandle @TrackArticleRead (Just filter) defaultCheckLoadedEvents initialState play decide toResult

