module Core.Mod.Newsletter.Id.Message.Field.AutoId where

import Data.Maybe (Maybe(..))

import Proem

import Core.Message.Field.Field (class IsField, defaultShouldSanitizeInner)
import Core.Mod.Newsletter.Id.Id (NewsletterId)
import Core.Mod.Id.Message.Field.AutoId as Base
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Newtype (class Newtype)

type Id = NewsletterId

newtype IdField = IdField Id

instance IsField IdField Id () where
  name = "Id"

  description = "Newsletter ID"

  presence = Base.presence

  sanitize = Base.sanitize

  shouldSanitizeInner = defaultShouldSanitizeInner

  cli =
    { description: "Newsletter ID"
    , multiline: false
    , choices: Nothing
    }

derive instance Newtype IdField _
derive newtype instance ReadForeign IdField
derive newtype instance WriteForeign IdField
derive newtype instance Eq IdField
derive newtype instance Show IdField
