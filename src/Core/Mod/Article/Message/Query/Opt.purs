module Core.Mod.Article.Message.Query.Opt where

import Proem

import Core.Message.Query.Payload (Fold, Need)
import Core.Mod.Article.Title.Message.Query.Opt (TitleOpt, TitleInnerNeeds)
import Core.Mod.Article.Lead.Message.Query.Opt (LeadOpt, LeadInnerNeeds)
import Core.Mod.Article.Illustrations.Message.Query.Opt (IllustrationsOpt, IllustrationsInnerNeeds)
import Core.Mod.Article.Content.Message.Query.Opt (ContentOpt, ContentInnerNeeds)
import Core.Mod.Author.Message.Query.Opt (AuthorOpt, AuthorInnerNeeds)
import Core.Mod.Book.Message.Query.Opt (BookOpt, BookInnerNeeds)

type ArticleOpt = Fold ArticleOpt_

type ArticleOpt_ = Ɩ

type ArticleInnerNeeds = Fold ArticleInnerNeeds_

type ArticleInnerNeeds_ =
  { id :: Need Ɩ Ɩ
  , legacyId :: Need Ɩ Ɩ
  , slug :: Need Ɩ Ɩ
  , title :: Need TitleOpt TitleInnerNeeds
  , lead :: Need LeadOpt LeadInnerNeeds
  , notes :: Need Ɩ Ɩ
  , illustrations :: Need IllustrationsOpt IllustrationsInnerNeeds
  , content :: Need ContentOpt ContentInnerNeeds
  , theme :: Need Ɩ Ɩ
  , books :: Need BookOpt BookInnerNeeds
  , author :: Need AuthorOpt AuthorInnerNeeds
  }
