module Core.Feat.Review.Message.Query.SearchArticles.Field.Needs where

import Data.Maybe (Maybe(..))

import Proem

import Core.Message.Field.Field (class IsField, Presence(..), Sanitized(..), defaultShouldSanitizeInner)
import Core.Message.Query.Payload (Need(..), NeedField)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Newtype (class Newtype)
import Core.Mod.Book.Message.Query.Opt (BookOpt, BookInnerNeeds)
import Core.Mod.Article.Illustrations.Message.Query.Opt (IllustrationsOpt, IllustrationsInnerNeeds)
import Core.Mod.Article.Content.Message.Query.Opt (ContentOpt, ContentInnerNeeds)
import Core.Mod.Article.Lead.Message.Query.Opt (LeadOpt, LeadInnerNeeds)
import Core.Mod.Article.Title.Message.Query.Opt (TitleOpt, TitleInnerNeeds)
import Core.Mod.Author.Message.Query.Opt (AuthorOpt, AuthorInnerNeeds)

type Needs =
  { id :: Need Ɩ Ɩ
  , legacyId :: Need Ɩ Ɩ
  , title :: Need TitleOpt TitleInnerNeeds
  , lead :: Need LeadOpt LeadInnerNeeds
  , notes :: Need Ɩ Ɩ
  , sources :: Need Ɩ Ɩ
  , content :: Need ContentOpt ContentInnerNeeds
  , theme :: Need Ɩ Ɩ
  , books :: Need BookOpt BookInnerNeeds
  , author :: Need AuthorOpt AuthorInnerNeeds
  , onFrontPages :: Need Ɩ Ɩ
  , illustrations :: Need IllustrationsOpt IllustrationsInnerNeeds
  , slug :: Need Ɩ Ɩ
  , magazineSection :: Need Ɩ Ɩ
  , magazineIssuePageNumber :: Need Ɩ Ɩ
  , seoUpdatedAt :: Need Ɩ Ɩ
  }

defaultNeeds :: Needs
defaultNeeds =
  { id: NotNeeded
  , legacyId: NotNeeded
  , title: NotNeeded
  , lead: NotNeeded
  , notes: NotNeeded
  , sources: NotNeeded
  , content: NotNeeded
  , theme: NotNeeded
  , books: NotNeeded
  , author: NotNeeded
  , onFrontPages: NotNeeded
  , illustrations: NotNeeded
  , slug: NotNeeded
  , magazineSection: NotNeeded
  , magazineIssuePageNumber: NotNeeded
  , seoUpdatedAt: NotNeeded
  }

type NeedsFieldChildren =
  (id :: NeedField Ɩ Ɩ
  , legacyId :: NeedField Ɩ Ɩ
  , title :: NeedField TitleOpt TitleInnerNeeds
  , lead :: NeedField LeadOpt LeadInnerNeeds
  , notes :: NeedField Ɩ Ɩ
  , sources :: NeedField Ɩ Ɩ
  , content :: NeedField ContentOpt ContentInnerNeeds
  , theme :: NeedField Ɩ Ɩ
  , books :: NeedField BookOpt BookInnerNeeds
  , author :: NeedField AuthorOpt AuthorInnerNeeds
  , onFrontPages :: NeedField Ɩ Ɩ
  , illustrations :: NeedField IllustrationsOpt IllustrationsInnerNeeds
  , slug :: NeedField Ɩ Ɩ
  , magazineSection :: NeedField Ɩ Ɩ
  , magazineIssuePageNumber :: NeedField Ɩ Ɩ
  , seoUpdatedAt :: NeedField Ɩ Ɩ
  )

newtype NeedsField = NeedsField Needs

description :: String
description = "Article needs"

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

