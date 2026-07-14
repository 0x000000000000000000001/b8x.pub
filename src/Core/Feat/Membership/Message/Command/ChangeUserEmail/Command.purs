module Core.Feat.Membership.Message.Command.ChangeUserEmail.Command
  ( ChangeUserEmail(..)
  ) where

import Proem hiding ((&&), (||))

import Core.Feat.Membership.Message.Command.ChangeUserEmail.Decide (decide)
import Core.Feat.Membership.Message.Command.ChangeUserEmail.Filter (filter)
import Core.Feat.Membership.Message.Command.ChangeUserEmail.Payload (Fields, Payload)
import Core.Feat.Membership.Message.Command.ChangeUserEmail.Play (play)
import Core.Feat.Membership.Message.Command.ChangeUserEmail.Result (Result, toResult)
import Core.Feat.Membership.Message.Command.ChangeUserEmail.State (State, initialState)
import Core.Feat.Membership.Message.Command.Service.VerifyEmailUniqueness (verifyEmailUniqueness)
import Core.Message.Command.Command (class IsCommand, class IsProtectedAgainstConcurrency, defaultMaxConcurrencyRetries, ConcurrencyPriority(..), defaultCheckLoadedEvents, defaultHandle)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Generic.Rep (class Generic)
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)
import Util.Type.Random (class Random)
import Util.Type.Type (class Reflect, reflectConstructorName)

newtype ChangeUserEmail = ChangeUserEmail Payload

derive instance Newtype ChangeUserEmail _
derive instance Generic ChangeUserEmail _
derive newtype instance Random ChangeUserEmail
derive newtype instance WriteForeign ChangeUserEmail
derive newtype instance ReadForeign ChangeUserEmail

instance Reflect ChangeUserEmail where
  reflectName = reflectConstructorName @ChangeUserEmail

instance IsProtectedAgainstConcurrency ChangeUserEmail where
  priority = Safe
  maxRetries = defaultMaxConcurrencyRetries
  baseRetryDelayMs = 100

instance
  IsCommand
    ChangeUserEmail
    State
    Fields
    Payload
    Result
  where
  description = "Change the email of a user"

  handle payload = do
    verifyEmailUniqueness payload.email

    defaultHandle @ChangeUserEmail (Just filter) defaultCheckLoadedEvents initialState play decide toResult payload

  