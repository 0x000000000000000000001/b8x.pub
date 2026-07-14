module Core.Event.ArticleWritten.Payload where

import Core.Mod.Article.Author.Author (Author)
import Core.Mod.Article.Content.Content (Content)
import Core.Mod.Article.Id.Id (ArticleId)
import Core.Mod.Article.Illustrations.Illustrations (Illustrations)
import Core.Mod.Article.Lead.Lead (Lead)
import Core.Mod.Article.Notes.Notes (Notes)
import Core.Mod.Article.Theme.Theme (Theme)
import Core.Mod.Article.Title.Title (Title)
import Core.Mod.Article.Sources.Sources (Sources)
import Core.Mod.Article.Slug.Slug (Slug)
import Core.Mod.Book.Id.Id (BookId)
import Core.Mod.Article.LegacyId.LegacyId (LegacyId)
import Core.Mod.Article.MagazineIssue.MagazineIssue (MagazineIssue)
import Data.Maybe (Maybe)

type Payload =
  { id :: ArticleId
  , legacyId :: LegacyId
  , books :: Array BookId
  , author :: Author
  , theme :: Maybe Theme
  , title :: Title
  , lead :: Lead
  , notes :: Notes
  , sources :: Sources
  , content :: Content
  , illustrations :: Illustrations
  , profitable :: Boolean
  , slug :: Slug
  , magazineIssue :: Maybe MagazineIssue
  }
