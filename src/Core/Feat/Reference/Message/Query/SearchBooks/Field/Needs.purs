module Core.Feat.Reference.Message.Query.SearchBooks.Field.Needs where

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
  , year :: Need Ɩ Ɩ
  , cover :: Need CoverOpt CoverInnerNeeds
  , authors :: Need Ɩ Ɩ
  , editor :: Need Ɩ Ɩ
  }

defaultNeeds :: Needs
defaultNeeds =
  { id: NotNeeded
  , name: NotNeeded
  , year: NotNeeded
  , cover: NotNeeded
  , authors: NotNeeded
  , editor: NotNeeded
  }

type NeedsFieldChildren =
  (id :: NeedField Ɩ Ɩ
  , name :: NeedField Ɩ Ɩ
  , year :: NeedField Ɩ Ɩ
  , cover :: NeedField CoverOpt CoverInnerNeeds
  , authors :: NeedField Ɩ Ɩ
  , editor :: NeedField Ɩ Ɩ
  )

newtype NeedsField = NeedsField Needs

description :: String
description = "Book needs"

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
