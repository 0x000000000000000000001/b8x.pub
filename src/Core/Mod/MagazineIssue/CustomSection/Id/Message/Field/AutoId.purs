module Core.Mod.MagazineIssue.CustomSection.Id.Message.Field.AutoId where

import Proem

import Core.Message.Field.Field (class IsField, defaultShouldSanitizeInner)
import Core.Mod.Id.Message.Field.AutoId as Auto
import Core.Mod.MagazineIssue.CustomSection.Id.Id as Base
import Core.Mod.MagazineIssue.CustomSection.Id.Message.Field.Util as Util
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)

type CustomSectionId = Base.CustomSectionId

newtype CustomSectionIdField = CustomSectionIdField CustomSectionId

instance IsField CustomSectionIdField CustomSectionId () where
  name = "CustomSectionId"

  description = Util.description

  presence = Auto.presence

  sanitize = Auto.sanitize

  shouldSanitizeInner = defaultShouldSanitizeInner

  cli =
    { description: Util.description
    , multiline: false
    , choices: Nothing
    }

derive instance Newtype CustomSectionIdField _
derive newtype instance ReadForeign CustomSectionIdField
derive newtype instance WriteForeign CustomSectionIdField
derive newtype instance Eq CustomSectionIdField
derive newtype instance Show CustomSectionIdField
