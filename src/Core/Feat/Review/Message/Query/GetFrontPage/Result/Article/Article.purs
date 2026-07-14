module Core.Feat.Review.Message.Query.GetFrontPage.Result.Article.Article where

import Proem

import Core.Message.Query.Result (Fold, Return)
import Core.Mod.Book.Message.Query.Result.Books (Books)
import Core.Feat.Review.Message.Query.GetFrontPage.Result.Article.Illustrations (Illustrations)

import Core.Mod.Article.Content.Content (Content)
import Core.Mod.Article.Id.Id (ArticleId)
import Core.Mod.Article.Lead.Message.Query.Result (Lead)
import Core.Mod.Article.Theme.Theme (Theme)
import Core.Mod.Article.Title.Title (Title)
import Core.Mod.Article.Slug.Slug (Slug)
import Core.Mod.Article.Notes.Notes (Notes)
import Core.Mod.Author.Message.Query.Result (Author)
import Data.Lens (Lens')
import Data.Lens.Record (prop)
import Data.Maybe (Maybe)

type Article = Fold (Maybe ArticleId) (Maybe Article_)

type Article_ =
  { id :: Return ArticleId
  , legacyId :: Return (Maybe Int)
  , slug :: Return Slug
  , title :: Return Title
  , lead :: Return Lead
  , notes :: Return Notes
  , content :: Return Content
  , theme :: Return (Maybe Theme)
  , books :: Return Books
  , author :: Return (Maybe Author)
  , illustrations :: Return Illustrations
  }

_title :: Lens' Article_ (Return Title)
_title = prop (π @"title")

_lead :: Lens' Article_ (Return Lead)
_lead = prop (π @"lead")

_notes :: Lens' Article_ (Return Notes)
_notes = prop (π @"notes")

_content :: Lens' Article_ (Return Content)
_content = prop (π @"content")

_books :: Lens' Article_ (Return Books)
_books = prop (π @"books")
