module Core.Feat.Review.Message.Query.ListMostReadArticles.Field.Blacklist where

import Data.Maybe (Maybe(..))

import Proem

import Core.Message.Field.Field (class IsField, Presence(..), Sanitized(..), defaultShouldSanitizeInner)
import Core.Mod.Article.Id.Id (ArticleId)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Newtype (class Newtype)

type Blacklist = Array ArticleId

newtype BlacklistField = BlacklistField Blacklist

description :: String
description = "Blacklisted article IDs"

instance IsField BlacklistField Blacklist () where
  name = "Blacklist"

  description = description

  presence = Required

  sanitize = κ Intact

  shouldSanitizeInner = defaultShouldSanitizeInner

  cli =
    { description
    , multiline: false
    , choices: Nothing
    }

derive instance Newtype BlacklistField _
derive newtype instance ReadForeign BlacklistField
derive newtype instance WriteForeign BlacklistField
derive newtype instance Eq BlacklistField
derive newtype instance Show BlacklistField
