module Core.Mod.Book.Id.Message.Field.AutoId where

import Data.Maybe (Maybe(..))

import Proem

import Core.Message.Field.Field (class IsField, defaultShouldSanitizeInner)
import Core.Mod.Book.Id.Message.Field.Util as Util
import Core.Mod.Book.Id.Id (BookId)
import Core.Mod.Id.Message.Field.AutoId as Base
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Newtype (class Newtype)

type Id = BookId

newtype IdField = IdField Id

instance IsField IdField Id () where
  name = "Id"

  description = Util.description

  presence = Base.presence

  sanitize = Base.sanitize

  shouldSanitizeInner = defaultShouldSanitizeInner

  cli =
    { description: Util.description
    , multiline: false
    , choices: Nothing
    }

derive instance Newtype IdField _
derive newtype instance ReadForeign IdField
derive newtype instance WriteForeign IdField
derive newtype instance Eq IdField
derive newtype instance Show IdField
