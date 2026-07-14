module Inter.Ui.Page.Home.Util
  ( bandArticleNeeds
  , cleanNonEmpty
  , cleanNonEmptyStripTags
  , cleanWpNonEmpty
  , toUiSearchArticle
  ) where

import Core.Mod.Article.Content.Excerpt.CutStrategy (CutStrategy(..), Suffix(..), SuffixValue(..))
import Proem

import Core.Message.Query.Payload (Fold(..), Need(..))
import Core.Feat.Review.Message.Query.SearchArticles.Field.Needs (Needs, defaultNeeds) as SearchArticlesNeeds
import Core.Mod.Article.Lead.Clean as LeadClean
import Core.Mod.Article.Title.Clean as TitleClean
import Core.Mod.Book.Cover.Message.Query.Opt (defaultCoverOpt)
import Data.Maybe (Maybe(..))
import Util.Html.Clean.Clean (TagList(..), untagAll)
import Core.Message.Query.Result as QueryResult
import Core.Message.Query.Result (Return)
import Core.Mod.Html.Html (NonEmptyHtml)
import Data.Newtype (unwrap)
import Util.Html.Clean.Render.Render (SanitizedHtmlString, sanitizeHtml)
import Util.Html.Clean.Render.WpAutop.WpAutop (wpAutop)
import Inter.Ui.Type.Model (UiSearchArticle)
import Core.Mod.Article.Id.Id (ArticleId)
import Core.Mod.Article.Theme.Theme (Theme)
import Core.Mod.Article.Content.Content (Content)
import Core.Mod.Article.Notes.Notes (Notes)
import Core.Mod.Article.Sources.Sources (Sources)
import Core.Mod.Article.Lead.Message.Query.Result (Lead)
import Core.Mod.Article.Title.Title (Title)
import Core.Mod.Author.Message.Query.Result (Author)
import Core.Mod.Book.Message.Query.Result.Books (Books)
import Core.Mod.Image.Message.Query.Result (Illustration)
import Core.Mod.Article.Slug.Slug (Slug)

bandArticleNeeds :: SearchArticlesNeeds.Needs
bandArticleNeeds = SearchArticlesNeeds.defaultNeeds
  { id = Needed ι ι
  , slug = Needed ι ι
  , title = Needed
      { untagHtml:
          { whitelist: TitleClean.defaultUntagWhitelist
          , blacklistInWhitelist: Tags []
          }
      }
      ι
  , lead = Needed
      { fallbackToContentExcerpt: Just { cutStrategy: OnSentenceEnd { min: 200, max: 300, suffix: OnlyOnHardSentenceCut Default }, newlineReplacement: Just " " }
      , untagHtml:
          { whitelist: LeadClean.defaultUntagWhitelist
          , blacklistInWhitelist: Tags []
          }
      }
      { isFallback: Needed ι ι
      }
  , author = Needed ι { id: Needed ι ι, name: Needed ι ι, biography: NotNeeded, portrait: NotNeeded }
  , books = Needed (Unfolded ι) $ Unfolded
      { id: NotNeeded
      , name: Needed ι ι
      , year: NotNeeded
      , cover: Needed defaultCoverOpt { src: Needed { absolute: true } ι, dimensions: NotNeeded }
      , authors: Needed ι ι
      , editor: Needed ι ι
      }
  , illustrations = Needed
      { priorizeRatio: Just (16.0 / 9.0)
      , fallbackToBookCovers: true
      }
      { image: Needed ι
          { src: Needed { absolute: true } ι
          , dimensions: Needed ι { width: Needed ι ι, height: Needed ι ι }
          }
      , caption: Needed ι ι
      , isFallback: Needed ι ι
      }
  , magazineIssuePageNumber = Needed ι ι
  , magazineSection = Needed ι ι
  }

cleanNonEmpty :: NonEmptyHtml -> SanitizedHtmlString
cleanNonEmpty c = sanitizeHtml (unwrap c)

cleanNonEmptyStripTags :: NonEmptyHtml -> SanitizedHtmlString
cleanNonEmptyStripTags c = sanitizeHtml (untagAll false (unwrap c))

cleanWpNonEmpty :: NonEmptyHtml -> SanitizedHtmlString
cleanWpNonEmpty c = sanitizeHtml (wpAutop false (unwrap c))

toUiSearchArticle
  :: ∀ r
   . { id :: Return ArticleId
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
     | r
     }
  -> UiSearchArticle
toUiSearchArticle art =
  { id: art.id
  , legacyId: art.legacyId
  , title: art.title <#> cleanNonEmpty
  , lead: art.lead <#> \l -> { lead: l.lead <#> map cleanNonEmpty, isFallback: l.isFallback }
  , content: art.content <#> cleanWpNonEmpty
  , notes: art.notes <#> map cleanWpNonEmpty
  , sources: art.sources <#> map cleanWpNonEmpty
  , theme: art.theme
  , author: art.author <#> map (\a -> { id: a.id, name: a.name <#> cleanNonEmptyStripTags, biography: a.biography <#> map cleanNonEmpty, portrait: a.portrait })
  , books: art.books <#> case _ of
      QueryResult.Unfolded bks -> QueryResult.Unfolded $ bks <#> \b ->
        { id: b.id
        , name: b.name <#> cleanNonEmpty
        , year: b.year
        , cover: b.cover
        , authors: b.authors <#> map (\a -> { id: a.id, name: cleanNonEmptyStripTags a.name })
        , editor: b.editor <#> map cleanNonEmpty
        }
      QueryResult.Folded f -> QueryResult.Folded f
  , illustrations: art.illustrations <#> map (\ill -> { image: ill.image, caption: ill.caption <#> map cleanNonEmpty, isFallback: ill.isFallback })
  , slug: art.slug
  }
