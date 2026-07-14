module Core.Feat.Review.Message.Query.GetArticleQuote.Result where

import Core.Message.Query.Result (Return)
import Core.Mod.Article.Id.Id (ArticleId)
import Core.Mod.Article.Lead.Message.Query.Result (Lead)
import Core.Mod.Article.Slug.Slug (Slug)
import Core.Mod.Article.Title.Title (Title)
import Core.Mod.Author.Message.Query.Result (Author)
import Data.Maybe (Maybe)
import Core.Mod.Image.Message.Query.Result (Illustration)
import Core.Mod.Book.Message.Query.Result.Books (Books)

type Result = Maybe
  { quote :: String
  , article :: Article
  , slug :: Slug
  }

type Article =
  { id :: Return ArticleId
  , title :: Return Title
  , lead :: Return Lead
  , books :: Return Books
  , author :: Return (Maybe Author)
  , illustrations :: Return (Array Illustration)
  , slug :: Return Slug
  }
