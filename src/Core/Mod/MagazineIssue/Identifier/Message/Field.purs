module Core.Mod.MagazineIssue.Identifier.Message.Field where

import Data.Maybe (Maybe(..))

import Proem

import Core.Message.Field.Field (class IsField, Presence(..), Sanitized(..), defaultShouldSanitizeInner)
import Core.Mod.MagazineIssue.Identifier.MagazineIssueIdentifier as Base
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Newtype (class Newtype)

newtype MagazineIssueIdentifierField = MagazineIssueIdentifierField Base.MagazineIssueIdentifier

description :: String
description = "A magazine issue identifier (ID or slug)"

instance IsField MagazineIssueIdentifierField Base.MagazineIssueIdentifier () where
  name = "MagazineIssueIdentifier"

  description = "A magazine issue identifier (ID or slug)"

  presence = Required

  sanitize = κ Intact

  shouldSanitizeInner = defaultShouldSanitizeInner
  
  cli =
    { description
    , multiline: false
    , choices: Nothing
    }

derive instance Newtype MagazineIssueIdentifierField _
derive newtype instance ReadForeign MagazineIssueIdentifierField
derive newtype instance WriteForeign MagazineIssueIdentifierField
derive newtype instance Eq MagazineIssueIdentifierField
derive newtype instance Show MagazineIssueIdentifierField
