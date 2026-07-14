module Core.Feat.Reference.Message.Query.SearchMagazineIssues.Field.Needs where

import Data.Maybe (Maybe(..))

import Proem

import Core.Message.Field.Field (class IsField, Presence(..), Sanitized(..), defaultShouldSanitizeInner)
import Core.Message.Query.Payload (Need(..), NeedField)
import Core.Mod.Book.Cover.Message.Query.Opt (CoverOpt, CoverInnerNeeds)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Newtype (class Newtype)

type Needs =
  { id :: Need Ɩ Ɩ
  , name :: Need Ɩ Ɩ
  , legacyId :: Need Ɩ Ɩ
  , special :: Need Ɩ Ɩ
  , complement :: Need Ɩ Ɩ
  , number :: Need Ɩ Ɩ
  , cover :: Need CoverOpt CoverInnerNeeds
  , slug :: Need Ɩ Ɩ
  , seoUpdatedAt :: Need Ɩ Ɩ
  }

defaultNeeds :: Needs
defaultNeeds =
  { id: NotNeeded
  , name: NotNeeded
  , legacyId: NotNeeded
  , special: NotNeeded
  , complement: NotNeeded
  , number: NotNeeded
  , cover: NotNeeded
  , slug: NotNeeded
  , seoUpdatedAt: NotNeeded
  }

type NeedsFieldChildren =
  (id :: NeedField Ɩ Ɩ
  , name :: NeedField Ɩ Ɩ
  , legacyId :: NeedField Ɩ Ɩ
  , special :: NeedField Ɩ Ɩ
  , complement :: NeedField Ɩ Ɩ
  , number :: NeedField Ɩ Ɩ
  , cover :: NeedField CoverOpt CoverInnerNeeds
  , slug :: NeedField Ɩ Ɩ
  , seoUpdatedAt :: NeedField Ɩ Ɩ
  )

newtype NeedsField = NeedsField Needs

description :: String
description = "Magazine issue needs"

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
