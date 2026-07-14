module Core.Feat.Membership.Message.Command.RegisterUser.Command
  ( RegisterUser(..)
  ) where

import Core.Feat.Membership.Message.Command.RegisterUser.Decide (decide)
import Core.Feat.Membership.Message.Command.RegisterUser.Filter (filter)
import Core.Feat.Membership.Message.Command.RegisterUser.Payload (Fields, Payload)
import Core.Feat.Membership.Message.Command.RegisterUser.Play (play)
import Core.Feat.Membership.Message.Command.RegisterUser.Result (Result, toResult)
import Core.Feat.Membership.Message.Command.RegisterUser.State (State, initialState)
import Core.Feat.Membership.Message.Command.Service.VerifyEmailUniqueness (verifyEmailUniqueness_)
import Core.Message.Command.Command (class IsCommand, class IsProtectedAgainstConcurrency, defaultMaxConcurrencyRetries, ConcurrencyPriority(..), defaultHandle)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Generic.Rep (class Generic)
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)
import Util.Type.Random (class Random)
import Util.Type.Type (class Reflect, reflectConstructorName)

newtype RegisterUser = RegisterUser Payload

derive instance Newtype RegisterUser _
derive instance Generic RegisterUser _
derive newtype instance Random RegisterUser
derive newtype instance WriteForeign RegisterUser
derive newtype instance ReadForeign RegisterUser

instance Reflect RegisterUser where
  reflectName = reflectConstructorName @RegisterUser

instance IsProtectedAgainstConcurrency RegisterUser where
  priority = Safe
  maxRetries = defaultMaxConcurrencyRetries
  baseRetryDelayMs = 100

instance
  IsCommand
    RegisterUser
    State
    Fields
    Payload
    Result
  where
  description = "Register a user"

  handle payload = defaultHandle @RegisterUser (Just filter)
    (verifyEmailUniqueness_ payload.email)
    initialState
    play
    decide
    toResult
    payload

  