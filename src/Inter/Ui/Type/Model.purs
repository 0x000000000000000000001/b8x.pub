module Inter.Ui.Type.Model where

import Core.Message.Query.Result (Return, Fold)
import Core.Mod.Article.Id.Id (ArticleId)
import Core.Mod.Article.Slug.Slug (Slug)
import Core.Mod.Article.Theme.Theme (Theme)
import Core.Mod.Book.Id.Id (BookId)
import Core.Mod.Book.Year.Year (Year)
import Core.Mod.Author.Id.Id (AuthorId)
import Core.Mod.Article.Projection.MagazineIssue (MagazineIssue)
import Core.Mod.Image.Message.Query.Result (Image)
import Data.Maybe (Maybe)
import Util.Html.Clean.Render.Render (SanitizedHtmlString)

type UiArticle =
  { id :: Return ArticleId
  , legacyId :: Return (Maybe Int)
  , title :: Return SanitizedHtmlString
  , lead :: Return UiLead
  , notes :: Return (Maybe SanitizedHtmlString)
  , sources :: Return (Maybe SanitizedHtmlString)
  , content :: Return SanitizedHtmlString
  , theme :: Return (Maybe Theme)
  , books :: Return (Fold (Array BookId) (Array UiBook))
  , author :: Return (Maybe UiAuthor)
  , illustrations :: Return (Array UiIllustration)
  , magazineIssue :: Return (Maybe MagazineIssue)
  }

type UiSearchArticle =
  { id :: Return ArticleId
  , legacyId :: Return (Maybe Int)
  , title :: Return SanitizedHtmlString
  , lead :: Return UiLead
  , notes :: Return (Maybe SanitizedHtmlString)
  , sources :: Return (Maybe SanitizedHtmlString)
  , content :: Return SanitizedHtmlString
  , theme :: Return (Maybe Theme)
  , books :: Return (Fold (Array BookId) (Array UiBook))
  , author :: Return (Maybe UiAuthor)
  , illustrations :: Return (Array UiIllustration)
  , slug :: Return Slug
  }

type UiFrontPageResult =
  { topLeft :: Return (Fold (Maybe ArticleId) (Maybe UiSearchArticle))
  , topRight :: Return (Fold (Maybe ArticleId) (Maybe UiSearchArticle))
  , center :: Return (Fold (Maybe ArticleId) (Maybe UiSearchArticle))
  , bottomLeft :: Return (Fold (Maybe ArticleId) (Maybe UiSearchArticle))
  , bottomRight :: Return (Fold (Maybe ArticleId) (Maybe UiSearchArticle))
  }

type UiLead =
  { lead :: Return (Maybe SanitizedHtmlString)
  , isFallback :: Return Boolean
  }

type UiIllustration =
  { image :: Return Image
  , caption :: Return (Maybe SanitizedHtmlString)
  , isFallback :: Return Boolean
  }

type UiAuthor =
  { id :: Return AuthorId
  , name :: Return SanitizedHtmlString
  , biography :: Return (Maybe SanitizedHtmlString)
  , portrait :: Return (Maybe Image)
  }

type UiBookAuthor =
  { id :: AuthorId
  , name :: SanitizedHtmlString
  }

type UiBook =
  { id :: Return BookId
  , name :: Return SanitizedHtmlString
  , year :: Return (Maybe Year)
  , cover :: Return (Maybe Image)
  , authors :: Return (Array UiBookAuthor)
  , editor :: Return (Maybe SanitizedHtmlString)
  }
