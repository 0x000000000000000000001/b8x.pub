module Core.Feat.Membership.Message.Command.TrackUserDonated.Command
  (TrackUserDonated(..)
  ) where

import Core.Message.Command.Command (class IsCommand, class IsProtectedAgainstConcurrency, defaultMaxConcurrencyRetries, ConcurrencyPriority(..), defaultCheckLoadedEvents, defaultHandle)
import Core.Feat.Membership.Message.Command.TrackUserDonated.Decide (decide)
import Core.Feat.Membership.Message.Command.TrackUserDonated.Filter (filter)
import Core.Feat.Membership.Message.Command.TrackUserDonated.Payload (Payload, Fields)
import Core.Feat.Membership.Message.Command.TrackUserDonated.Play (play)
import Core.Feat.Membership.Message.Command.TrackUserDonated.Result (Result, toResult)
import Core.Feat.Membership.Message.Command.TrackUserDonated.State (State, initialState)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Generic.Rep (class Generic)
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)
import Util.Type.Random (class Random)
import Util.Type.Type (class Reflect, reflectConstructorName)

newtype TrackUserDonated = TrackUserDonated Payload

derive instance Newtype TrackUserDonated _
derive instance Generic TrackUserDonated _
derive newtype instance Random TrackUserDonated
derive newtype instance WriteForeign TrackUserDonated
derive newtype instance ReadForeign TrackUserDonated

instance Reflect TrackUserDonated where
  reflectName = reflectConstructorName @TrackUserDonated

instance IsProtectedAgainstConcurrency TrackUserDonated where
  priority = Safe
  maxRetries = defaultMaxConcurrencyRetries
  baseRetryDelayMs = 100

instance
  IsCommand
    TrackUserDonated
    State
    Fields
    Payload
    Result
  where
  description = "Track a user donation"

  handle = defaultHandle @TrackUserDonated (Just filter) defaultCheckLoadedEvents initialState play decide toResult

  