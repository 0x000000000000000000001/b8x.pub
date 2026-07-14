module Core.Mod.MagazineIssue.Id.Message.Field.MaybeMagazineIssue where

import Proem
import Data.Maybe (Maybe(..))

import Core.Message.Field.Field (class IsField, Sanitized(..), defaultMaybePresence, defaultSanitize, defaultShouldSanitizeInner)
import Core.Mod.MagazineIssue.Id.Id (MagazineIssueId)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Newtype (class Newtype)

type MagazineIssue = Maybe MagazineIssueId

newtype MagazineIssueField = MagazineIssueField MagazineIssue

description :: String
description = "Magazine Issue ID"

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
