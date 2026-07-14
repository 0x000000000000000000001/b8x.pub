module Core.Mod.MagazineIssue.CustomSection.Id.Message.Field.AfterCustomSection where

import Proem

import Core.Message.Field.Field (class IsField, Sanitized(..), defaultMaybePresence, defaultSanitize, defaultShouldSanitizeInner)
import Core.Mod.MagazineIssue.CustomSection.Id.Id (CustomSectionId)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)

type AfterCustomSection = Maybe CustomSectionId

newtype AfterCustomSectionField = AfterCustomSectionField AfterCustomSection

description :: String
description = "Pagination cursor pointing to the last parsed custom section"

instance IsField AfterCustomSectionField AfterCustomSection () where
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

derive instance Newtype AfterCustomSectionField _
derive newtype instance ReadForeign AfterCustomSectionField
derive newtype instance WriteForeign AfterCustomSectionField
derive newtype instance Eq AfterCustomSectionField
derive newtype instance Show AfterCustomSectionField
