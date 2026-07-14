module Core.Feat.Reference.Message.Query.SearchAuthors.Field.Needs where

import Data.Maybe (Maybe(..))

import Proem

import Core.Message.Field.Field (class IsField, Presence(..), Sanitized(..), defaultShouldSanitizeInner)
import Core.Message.Query.Payload (Need(..), NeedField)
import Core.Mod.Image.Message.Query.Opt (ImageOpt, ImageInnerNeeds)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Newtype (class Newtype)

type Needs =
  { id :: Need Ɩ Ɩ
  , name :: Need Ɩ Ɩ
  , biography :: Need Ɩ Ɩ
  , legacyIds :: Need Ɩ Ɩ
  , portrait :: Need ImageOpt ImageInnerNeeds
  }

defaultNeeds :: Needs
defaultNeeds =
  { id: NotNeeded
  , name: NotNeeded
  , biography: NotNeeded
  , legacyIds: NotNeeded
  , portrait: NotNeeded
  }

type NeedsFieldChildren =
  (id :: NeedField Ɩ Ɩ
  , name :: NeedField Ɩ Ɩ
  , biography :: NeedField Ɩ Ɩ
  , legacyIds :: NeedField Ɩ Ɩ
  , portrait :: NeedField ImageOpt ImageInnerNeeds
  )

newtype NeedsField = NeedsField Needs

description :: String
description = "Author needs"

instance
  IsField
    NeedsField
    Needs
    NeedsFieldChildren
  where
  name = "Needs"

  description = description

  presence = Required

  sanitize = κ Intact

  shouldSanitizeInner = defaultShouldSanitizeInner

  cli =
    { description
    , multiline: false
    , choices: Nothing
    }

derive instance Newtype NeedsField _
derive newtype instance ReadForeign NeedsField
derive newtype instance WriteForeign NeedsField
derive newtype instance Eq NeedsField
derive newtype instance Show NeedsField
