module Core.Feat.Review.Message.Query.ListNewsletterArticles.Result where

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
import Core.Mod.Book.Message.Query.Result.Books (Books)
import Core.Mod.Image.Message.Query.Result (Illustration)
import Core.Mod.Newsletter.Id.Id (NewsletterId)
import Core.Mod.Time.Month (Month)
import Core.Mod.Time.Year (Year)
import Core.Mod.Time.Instant (Instant)
import Data.Maybe (Maybe)

type Newsletter
  = { id :: NewsletterId
    , index :: Int
    , scheduledFor ::
        { instant :: Instant
        , month :: Month
        , year :: Year
        }
    }

type Result
  = { articles :: Array Article
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
    , newsletters :: Return (Array Newsletter)
    }
