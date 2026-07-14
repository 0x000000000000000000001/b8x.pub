module Core.Feat.Review.Message.Query.GetArticleQuote.Field.Needs where

import Data.Maybe (Maybe(..))

import Proem

import Core.Message.Field.Field (class IsField, Presence(..), Sanitized(..), defaultShouldSanitizeInner)
import Core.Message.Query.Payload (Need(..), NeedField)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Newtype (class Newtype)
import Core.Mod.Book.Message.Query.Opt (BookOpt, BookInnerNeeds)
import Core.Mod.Article.Illustrations.Message.Query.Opt (IllustrationsOpt, IllustrationsInnerNeeds)
import Core.Mod.Article.Lead.Message.Query.Opt (LeadOpt, LeadInnerNeeds)
import Core.Mod.Article.Title.Message.Query.Opt (TitleOpt, TitleInnerNeeds)
import Core.Mod.Author.Message.Query.Opt (AuthorOpt, AuthorInnerNeeds)

type Needs =
  { id :: Need Ɩ Ɩ
  , title :: Need TitleOpt TitleInnerNeeds
  , lead :: Need LeadOpt LeadInnerNeeds
  , books :: Need BookOpt BookInnerNeeds
  , author :: Need AuthorOpt AuthorInnerNeeds
  , illustrations :: Need IllustrationsOpt IllustrationsInnerNeeds
  , slug :: Need Ɩ Ɩ
  }

defaultNeeds :: Needs
defaultNeeds =
  { id: NotNeeded
  , title: NotNeeded
  , lead: NotNeeded
  , books: NotNeeded
  , author: NotNeeded
  , illustrations: NotNeeded
  , slug: NotNeeded
  }

type NeedsFieldChildren =
  (id :: NeedField Ɩ Ɩ
  , title :: NeedField TitleOpt TitleInnerNeeds
  , lead :: NeedField LeadOpt LeadInnerNeeds
  , books :: NeedField BookOpt BookInnerNeeds
  , author :: NeedField AuthorOpt AuthorInnerNeeds
  , illustrations :: NeedField IllustrationsOpt IllustrationsInnerNeeds
  , slug :: NeedField Ɩ Ɩ
  )

newtype NeedsField = NeedsField Needs

description :: String
description = "Quote article needs"

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
