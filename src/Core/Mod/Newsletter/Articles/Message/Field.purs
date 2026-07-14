module Core.Mod.Newsletter.Articles.Message.Field where

import Data.Maybe (Maybe(..))

import Proem

import Core.Message.Field.Field (class IsField, Presence(..), Sanitized(..), defaultShouldSanitizeInner)
import Core.Mod.Newsletter.Articles.Articles as Base
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Newtype (class Newtype)

type Articles = Base.Articles

newtype ArticlesField = ArticlesField Articles

instance IsField ArticlesField Articles () where
  name = "Articles"

  description = "Newsletter articles"

  presence = Required

  sanitize _ = Intact

  shouldSanitizeInner = defaultShouldSanitizeInner

  cli =
    { description: "Newsletter articles"
    , multiline: false
    , choices: Nothing
    }

derive instance Newtype ArticlesField _
derive newtype instance ReadForeign ArticlesField
derive newtype instance WriteForeign ArticlesField
derive newtype instance Eq ArticlesField
derive newtype instance Show ArticlesField
