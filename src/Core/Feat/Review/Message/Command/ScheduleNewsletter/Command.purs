module Core.Feat.Review.Message.Command.ScheduleNewsletter.Command
  ( ScheduleNewsletter(..)
  ) where

import Proem

import Core.Message.Command.Command (class IsCommand, class IsProtectedAgainstConcurrency, defaultMaxConcurrencyRetries, ConcurrencyPriority(..), defaultCheckLoadedEvents, defaultHandle)
import Core.Feat.Review.Message.Command.ScheduleNewsletter.Decide (decide)
import Core.Feat.Review.Message.Command.ScheduleNewsletter.Filter (filter)
import Core.Feat.Review.Message.Command.ScheduleNewsletter.Payload (Payload, Fields)
import Core.Feat.Review.Message.Command.ScheduleNewsletter.Play (play)
import Core.Feat.Review.Message.Command.ScheduleNewsletter.Result (Result, toResult)
import Core.Feat.Newsletter.Message.Query.VerifyNewsletterUniqueness.VerifyNewsletterUniqueness (verifyNewsletterUniqueness)
import Core.Feat.Review.Message.Command.ScheduleNewsletter.State (State, initialState)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Generic.Rep (class Generic)
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)
import Util.Type.Random (class Random)
import Util.Type.Type (class Reflect, reflectConstructorName)

newtype ScheduleNewsletter = ScheduleNewsletter Payload

derive instance Newtype ScheduleNewsletter _
derive instance Generic ScheduleNewsletter _
derive newtype instance Random ScheduleNewsletter
derive newtype instance WriteForeign ScheduleNewsletter
derive newtype instance ReadForeign ScheduleNewsletter

instance Reflect ScheduleNewsletter where
  reflectName = reflectConstructorName @ScheduleNewsletter

instance IsProtectedAgainstConcurrency ScheduleNewsletter where
  priority = Safe
  maxRetries = defaultMaxConcurrencyRetries
  baseRetryDelayMs = 100

instance
  IsCommand
    ScheduleNewsletter
    State
    Fields
    Payload
    Result
  where
  description = "Schedule a newsletter"

  handle payload = do
    _ <- verifyNewsletterUniqueness { scheduledFor: payload.scheduledFor, articles: payload.articles }

    defaultHandle @ScheduleNewsletter (Just filter) defaultCheckLoadedEvents initialState play decide toResult payload

  