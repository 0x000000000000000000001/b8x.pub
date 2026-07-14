module Core.Mod.User.Id.Message.Field.TargetUser where

import Proem
import Control.Monad.Except as Control.Monad.Except

import Core.Message.Field.Field (class IsField, Presence(..), Sanitized(..), defaultShouldSanitizeInner)
import Core.Mod.User.Id.Id (UserId)
import Yoga.JSON (class ReadForeign, class WriteForeign, readImpl, writeImpl)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)
import Util.Type.Random (class Random)
import Core.Util.Validation (class IsRefinedType)
import Core.Message.Exception.MalformedPayloadValue (MalformedPayloadValue(..), MalformedPayloadValueRow)
import Core.Exception.Exception (inj)

data TargetUser = Me | ById UserId

derive instance Eq TargetUser

instance Show TargetUser where
  show Me = "Me"
  show (ById id) = "ById " <> show id

instance WriteForeign TargetUser where
  writeImpl Me = writeImpl "me"
  writeImpl (ById id) = writeImpl id

instance ReadForeign TargetUser where
  readImpl json = do
    str <- readImpl json
    if str == "me" then pure Me
    else ById <$> readImpl json



instance Random TargetUser where
  random = pure Me

newtype TargetUserField = TargetUserField TargetUser

derive instance Newtype TargetUserField _
derive newtype instance ReadForeign TargetUserField
derive newtype instance WriteForeign TargetUserField
derive newtype instance Eq TargetUserField
derive newtype instance Show TargetUserField

instance IsField TargetUserField TargetUser () where
  name = "TargetUser"
  description = "Target user ID, or 'me' for the current user"
  presence = Required
  sanitize = κ Intact
  shouldSanitizeInner = defaultShouldSanitizeInner
  cli =
    { description: "Target user ID, or 'me' for the current user"
    , multiline: false
    , choices: Nothing
    }

instance IsRefinedType TargetUser (MalformedPayloadValueRow ()) where
  makeFromJson _ json = case Control.Monad.Except.runExcept (readImpl json) of
    Right res -> Right res
    Left err -> Left $ inj $ MalformedPayloadValue { innerPath: Nothing, error: err }
