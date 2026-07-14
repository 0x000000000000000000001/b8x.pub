module Core.Feat.Membership.Message.Query.GetUserAccount.Field.Needs where

import Proem
import Control.Monad.Except as Control.Monad.Except

import Core.Message.Query.Payload (Need)
import Core.Util.Validation (class IsRefinedType)
import Core.Message.Exception.MalformedPayloadValue (MalformedPayloadValue(..), MalformedPayloadValueRow)
import Core.Exception.Exception (inj)
import Data.Either (Either(..))
import Data.Newtype (class Newtype)
import Yoga.JSON (class ReadForeign, class WriteForeign, readImpl)

import Core.Message.Field.Field (class IsField, Presence(..), Sanitized(..), defaultShouldSanitizeInner)
import Data.Maybe (Maybe(..))

import Util.Type.Random (class Random)

newtype Needs = Needs
  { adFree :: Need Unit Ɩ
  , hasPaidLastYear :: Need Unit Ɩ
  }

derive instance Newtype Needs _
derive newtype instance ReadForeign Needs
derive newtype instance WriteForeign Needs
derive newtype instance Random Needs
derive newtype instance Eq Needs
derive newtype instance Show Needs

newtype NeedsField = NeedsField Needs

derive instance Newtype NeedsField _
derive newtype instance ReadForeign NeedsField
derive newtype instance WriteForeign NeedsField

instance IsField NeedsField Needs () where
  name = "Needs"
  description = "Needs"
  presence = Required
  sanitize = κ Intact
  shouldSanitizeInner = defaultShouldSanitizeInner
  cli =
    { description: "Needs"
    , multiline: false
    , choices: Nothing
    }

instance IsRefinedType Needs (MalformedPayloadValueRow ()) where
  makeFromJson _ json = case Control.Monad.Except.runExcept (readImpl json) of
    Right res -> Right res
    Left err -> Left $ inj $ MalformedPayloadValue { innerPath: Nothing, error: err }
