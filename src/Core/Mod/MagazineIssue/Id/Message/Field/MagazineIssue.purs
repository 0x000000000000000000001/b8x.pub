module Core.Mod.MagazineIssue.Id.Message.Field.MagazineIssue where

import Proem

import Core.Message.Field.Field (class IsField, Presence(..), Sanitized(..), defaultShouldSanitizeInner)
import Core.Mod.MagazineIssue.Id.Id (MagazineIssueId)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)

type MagazineIssue = MagazineIssueId

newtype MagazineIssueField = MagazineIssueField MagazineIssue

description :: String
description = "Magazine Issue ID"

instance IsField MagazineIssueField MagazineIssue () where
  name = "MagazineIssue"

  description = description

  presence = Required

  sanitize = κ Intact

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
