module Core.Feat.Membership.Message.Command.SendMeMagicLink.Payload where

import Proem
import Control.Monad.Except as Control.Monad.Except
import Yoga.JSON (class ReadForeign, class WriteForeign, readImpl)
import Data.Either (Either(..))
import Data.Newtype (class Newtype)
import Data.Maybe (Maybe(..))
import Core.Message.Field.Field (class IsField, Presence(..), defaultSanitize, Sanitized(..))
import Core.Mod.Email.Message.Field (EmailField, Email)

import Util.Type.Random (class Random)
import Core.Util.Validation (class IsRefinedType)
import Core.Message.Exception.MalformedPayloadValue (MalformedPayloadValue(..), MalformedPayloadValueRow)
import Core.Exception.Exception (inj)

newtype ReturnTo = ReturnTo String

derive instance Newtype ReturnTo _
derive newtype instance ReadForeign ReturnTo
derive newtype instance WriteForeign ReturnTo
derive newtype instance Eq ReturnTo
derive newtype instance Show ReturnTo

instance Random ReturnTo where
  random = η $ ReturnTo "/"

instance IsRefinedType ReturnTo (MalformedPayloadValueRow ()) where
  makeFromJson _ json = case Control.Monad.Except.runExcept (readImpl json) of
    Left e -> Left $ inj $ MalformedPayloadValue { error: e, innerPath: Nothing }
    Right str -> pure (ReturnTo str)

newtype ReturnToField = ReturnToField ReturnTo

derive instance Newtype ReturnToField _
derive newtype instance ReadForeign ReturnToField
derive newtype instance WriteForeign ReturnToField
derive newtype instance Eq ReturnToField
derive newtype instance Show ReturnToField

instance IsField ReturnToField ReturnTo () where
  name = "returnTo"
  description = "The path to return to after login"
  presence = Required
  sanitize = defaultSanitize Intact
  shouldSanitizeInner = true
  cli = { description: "Return path", multiline: false, choices: Nothing }

type Fields =
  ( email :: EmailField
  , returnTo :: ReturnToField
  )

type Payload =
  { email :: Email
  , returnTo :: ReturnTo
  }
