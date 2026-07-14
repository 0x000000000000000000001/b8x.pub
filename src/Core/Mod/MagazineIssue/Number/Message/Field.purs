module Core.Mod.MagazineIssue.Number.Message.Field where

import Data.Maybe (Maybe(..))

import Proem

import Core.Message.Field.Field (class IsField, Presence(..), Sanitized(..), defaultShouldSanitizeInner)
import Core.Mod.MagazineIssue.Number.Number as Base
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Newtype (class Newtype)

type IssueNumber = Base.IssueNumber

newtype IssueNumberField = IssueNumberField IssueNumber

description :: String
description = "Magazine issue number"

instance IsField IssueNumberField IssueNumber () where
  name = "IssueNumber"

  description = description

  presence = Required

  sanitize _ = Intact

  shouldSanitizeInner = defaultShouldSanitizeInner

  cli =
    { description
    , multiline: false
    , choices: Nothing
    }

derive instance Newtype IssueNumberField _
derive newtype instance ReadForeign IssueNumberField
derive newtype instance WriteForeign IssueNumberField
derive newtype instance Eq IssueNumberField
derive newtype instance Show IssueNumberField
