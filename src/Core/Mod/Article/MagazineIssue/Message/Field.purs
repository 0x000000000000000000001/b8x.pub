module Core.Mod.Article.MagazineIssue.Message.Field where

import Proem

import Core.Message.Field.Field (class IsField, Sanitized(..), defaultMaybePresence, defaultSanitize, defaultShouldSanitizeInner)
import Core.Mod.Article.MagazineIssue.MagazineIssue as Base
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)

type MagazineIssue = Maybe Base.MagazineIssue

newtype MagazineIssueField = MagazineIssueField MagazineIssue

description :: String
description = "Magazine Issue"

instance IsField MagazineIssueField MagazineIssue () where
  name = "MagazineIssue"

  description = description

  presence = defaultMaybePresence

  sanitize = defaultSanitize ConsideredMissingSoShouldBeDefault

  shouldSanitizeInner = defaultShouldSanitizeInner

  cli =
    { description
    , multiline: false
    , choices: Nothing
    }

derive instance Newtype MagazineIssueField _
derive newtype instance ReadForeign MagazineIssueField
derive newtype instance WriteForeign MagazineIssueField
derive newtype instance Eq MagazineIssueField
derive newtype instance Show MagazineIssueField
