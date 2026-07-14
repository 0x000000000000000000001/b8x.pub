module Core.Feat.Review.Message.Query.SearchArticles.Result where

import Core.Message.Query.Result (Return)
import Core.Mod.Article.Content.Content (Content)
import Core.Mod.Article.Id.Id (ArticleId)
import Core.Mod.Article.Lead.Message.Query.Result (Lead)
import Core.Mod.Article.Notes.Notes (Notes)
import Core.Mod.Article.Sources.Sources (Sources)
import Core.Mod.Article.Slug.Slug (Slug)
import Core.Mod.Article.Theme.Theme (Theme)
import Core.Mod.Article.Title.Title (Title)
import Core.Mod.Author.Message.Query.Result (Author)
import Data.Maybe (Maybe)
import Core.Mod.Image.Message.Query.Result (Illustration)
import Core.Mod.Book.Message.Query.Result.Books (Books)
import Core.Mod.MagazineIssue.Section.Section (SectionF)
import Core.Mod.MagazineIssue.CustomSection.Name.Name as CustomSectionName
import Core.Mod.Time.Instant (Instant)

type Result
  = { articles :: Array Article
    , limit :: Int
    , hasNextPage :: Boolean
    }

type Article
  = { id :: Return ArticleId
    , legacyId :: Return (Maybe Int)
    , title :: Return Title
    , lead :: Return Lead
    , notes :: Return Notes
    , sources :: Return Sources
    , content :: Return Content
    , theme :: Return (Maybe Theme)
    , books :: Return Books
    , author :: Return (Maybe Author)
    , illustrations :: Return (Array Illustration)
    , slug :: Return Slug
    , magazineSection :: Return (Maybe (SectionF CustomSectionName.Name))
    , magazineIssuePageNumber :: Return (Maybe Int)
    , seoUpdatedAt :: Return Instant
    }
