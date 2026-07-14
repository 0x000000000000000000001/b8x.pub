module Core.Mod.MagazineIssue.Id.Message.Field.AfterMagazineIssue where

import Proem

import Core.Message.Field.Field (class IsField, Sanitized(..), defaultMaybePresence, defaultSanitize, defaultShouldSanitizeInner)
import Core.Mod.MagazineIssue.Id.Id (MagazineIssueId)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)

type AfterMagazineIssue = Maybe MagazineIssueId

newtype AfterMagazineIssueField = AfterMagazineIssueField AfterMagazineIssue

description :: String
description = "Pagination cursor pointing to the last parsed magazineIssue"

instance IsField AfterMagazineIssueField AfterMagazineIssue () where
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

derive instance Newtype AfterMagazineIssueField _
derive newtype instance ReadForeign AfterMagazineIssueField
derive newtype instance WriteForeign AfterMagazineIssueField
derive newtype instance Eq AfterMagazineIssueField
derive newtype instance Show AfterMagazineIssueField
