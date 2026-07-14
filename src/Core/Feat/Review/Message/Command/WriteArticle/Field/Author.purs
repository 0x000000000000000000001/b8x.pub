module Core.Feat.Review.Message.Command.WriteArticle.Field.Author where

import Proem

import Core.Message.Field.Field (class IsField, defaultShouldSanitizeInner, maybePresence)
import Core.Message.Field.Field as IsField
import Core.Mod.Article.Author.Message.Field as Base
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Newtype (class Newtype)

type Author = Base.Author

newtype AuthorField = AuthorField Author

instance IsField AuthorField Author () where
  name = IsField.name @Base.AuthorField

  description = IsField.description @Base.AuthorField

  presence = maybePresence "us"

  sanitize = IsField.sanitize @Base.AuthorField

  shouldSanitizeInner = defaultShouldSanitizeInner

  cli = IsField.cli @Base.AuthorField

derive instance Newtype AuthorField _
derive newtype instance ReadForeign AuthorField
derive newtype instance WriteForeign AuthorField
derive newtype instance Eq AuthorField
derive newtype instance Show AuthorField
