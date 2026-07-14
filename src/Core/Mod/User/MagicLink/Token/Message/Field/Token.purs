module Core.Mod.User.MagicLink.Token.Message.Field.Token where

import Data.Maybe (Maybe(..))

import Proem

import Core.Message.Field.Field (class IsField, Presence(..), Sanitized(..), defaultShouldSanitizeInner)
import Core.Mod.User.MagicLink.Token.Token as Base
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Newtype (class Newtype)

type Token = Base.Token

newtype TokenField = TokenField Token

description :: String
description = "Magic link token"

instance IsField TokenField Token () where
  name = "Token"

  description = description

  presence = Required

  sanitize = κ Intact

  shouldSanitizeInner = defaultShouldSanitizeInner

  cli =
    { description
    , multiline: false
    , choices: Nothing
    }

derive instance Newtype TokenField _
derive newtype instance ReadForeign TokenField
derive newtype instance WriteForeign TokenField
derive newtype instance Eq TokenField
derive newtype instance Show TokenField
