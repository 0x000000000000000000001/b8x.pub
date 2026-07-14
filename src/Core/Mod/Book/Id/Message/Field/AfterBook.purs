module Core.Mod.Book.Id.Message.Field.AfterBook where

import Proem

import Core.Message.Field.Field (class IsField, Sanitized(..), defaultMaybePresence, defaultSanitize, defaultShouldSanitizeInner)
import Core.Mod.Book.Id.Id (BookId)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)

type AfterBook = Maybe BookId

newtype AfterBookField = AfterBookField AfterBook

description :: String
description = "Pagination cursor pointing to the last parsed book"

instance IsField AfterBookField AfterBook () where
  name = "After"

  description = description

  presence = defaultMaybePresence

  sanitize = defaultSanitize (Corrected Nothing)

  shouldSanitizeInner = defaultShouldSanitizeInner

  cli =
    { description
    , multiline: false
    , choices: Nothing
    }

derive instance Newtype AfterBookField _
derive newtype instance ReadForeign AfterBookField
derive newtype instance WriteForeign AfterBookField
derive newtype instance Eq AfterBookField
derive newtype instance Show AfterBookField
