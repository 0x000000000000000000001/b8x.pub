module Core.Feat.Membership.Message.Command.UnregisterUser.Command
  ( UnregisterUser(..)
  ) where

import Core.Feat.Membership.Message.Command.UnregisterUser.Decide (decide)
import Core.Feat.Membership.Message.Command.UnregisterUser.Filter (filter)
import Core.Feat.Membership.Message.Command.UnregisterUser.Payload (Fields, Payload)
import Core.Feat.Membership.Message.Command.UnregisterUser.Play (play)
import Core.Feat.Membership.Message.Command.UnregisterUser.Result (Result, toResult)
import Core.Feat.Membership.Message.Command.UnregisterUser.State (State, initialState)
import Core.Message.Command.Command (class IsCommand, class IsProtectedAgainstConcurrency, defaultMaxConcurrencyRetries, ConcurrencyPriority(..), defaultCheckLoadedEvents, defaultHandle)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Generic.Rep (class Generic)
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)
import Util.Type.Random (class Random)
import Util.Type.Type (class Reflect, reflectConstructorName)

newtype UnregisterUser = UnregisterUser Payload

derive instance Newtype UnregisterUser _
derive instance Generic UnregisterUser _
derive newtype instance Random UnregisterUser
derive newtype instance WriteForeign UnregisterUser
derive newtype instance ReadForeign UnregisterUser

instance Reflect UnregisterUser where
  reflectName = reflectConstructorName @UnregisterUser

instance IsProtectedAgainstConcurrency UnregisterUser where
  priority = Safe
  maxRetries = defaultMaxConcurrencyRetries
  baseRetryDelayMs = 100

instance
  IsCommand
    UnregisterUser
    State
    Fields
    Payload
    Result
  where
  description = "Unregister a user"

  handle = defaultHandle @UnregisterUser (Just filter) defaultCheckLoadedEvents initialState play decide toResult

  