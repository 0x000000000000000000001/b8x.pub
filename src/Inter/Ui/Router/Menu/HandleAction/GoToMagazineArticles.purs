module Inter.Ui.Router.Menu.HandleAction.GoToMagazineArticles where

import Proem

import Core.Mod.Time.Year (Year)
import Data.Lens ((.~))
import Halogen (modify_, fork, raise, gets)
import Inter.Ui.Router.Menu.Type.MenuM (MenuM)
import Inter.Ui.Router.Menu.Type.Output as MenuOutput
import Inter.Ui.Type.IntentOrigin (IntentOrigin(..))
import Inter.Ui.Router.Menu.Type.State.State (_magazine)
import Inter.Ui.Router.Menu.Type.State.Magazine as Magazine
import Inter.Ui.Router.Menu.Type.State.Magazine (_articles, _page, _calendar)
import Inter.Ui.Remote (query, queryModify)
import Core.Feat.Review.Message.Query.SearchArticles.Query (SearchArticles(..))
import Core.Feat.Reference.Message.Query.GetMagazineCalendar.Query (GetMagazineCalendar(..))
import Inter.Ui.Page.Home.Util (bandArticleNeeds)
import Core.Mod.Article.Content.Excerpt.CutStrategy (CutStrategy(..), Suffix(..), SuffixValue(..))
import Core.Message.Query.Payload (Need(..))
import Util.Html.Clean.Clean (TagList(..), untagAll)
import Core.Mod.Article.Lead.Clean as LeadClean
import Data.Maybe (Maybe(..))
import Network.RemoteData (RemoteData(..))
import Core.Feat.Review.Message.Query.SearchArticles.Result (Article)
import Data.Foldable (for_)
import Core.Message.Query.Result as QueryResult
import Util.Type.String.ToString as Util.Type.String.ToString
import Util.Html.Clean.Render.Render (sanitizeHtml)
import Data.Newtype (unwrap)
import Inter.Ui.Capability.ArticleCache.Trans (putArticleCache)
import Data.Array as Array
import Inter.Ui.Capability.ArticleCache.ArticleCache (extractRequiredCacheValue, extractOptionalCacheValue)
import Core.Mod.MagazineIssue.Slug.Slug (Slug)
import Core.Feat.Review.Message.Query.SearchArticles.Projection.Projection (ArticleFilter(..))
import Core.Mod.Projection.Finder.Expectation.Expectation (Expectation(..))
import Core.Mod.Projection.Finder.BoundedLimit.BoundedLimit (BoundedLimit(..))
import Core.Mod.Projection.Finder.Sort (by, SortDirection(..))
import Inter.Ui.Router.Menu.HandleAction.Util.Scroll (scrollTopMenu)
import Data.Tuple (Tuple(..))
import Data.Map as Map

goToMagazineArticles :: IntentOrigin -> Maybe Year -> Slug -> MenuM Ɩ
goToMagazineArticles intent year slug = do
  modify_ (_magazine ◁ _page .~ Magazine.Articles { year, slug })

  when (intent == Internal) $ raise $ MenuOutput.MagazineIssueOpened slug

  scrollTopMenu

  modify_ (_magazine ◁ _articles .~ Loading)

  let
    findYearBySlug cal =
      let arr = Map.toUnfoldable cal
          found = Array.find (\(Tuple _ issues) -> Array.any (\i -> i.slug == slug) issues) arr
      in case found of
           Just (Tuple y _) -> Just y
           Nothing -> Nothing

  calendarState <- gets (_.magazine >>> _.calendar)
  case calendarState of
    NotAsked -> do
      ø $ queryModify
        ( \cRes -> case cRes of
            Success calRes -> do
              case year of
                Nothing -> do
                  case findYearBySlug (unwrap calRes).calendar of
                    Just y -> modify_ (_magazine ◁ _page .~ Magazine.Articles { year: Just y, slug })
                    Nothing -> ηι
                Just _ -> ηι
            _ -> ηι
        )
        (_magazine ◁ _calendar)
        (GetMagazineCalendar {})
    Success calRes -> do
      case year of
        Nothing -> do
          case findYearBySlug (unwrap calRes).calendar of
            Just y -> modify_ (_magazine ◁ _page .~ Magazine.Articles { year: Just y, slug })
            Nothing -> ηι
        Just _ -> ηι
    _ -> ηι

  res <- query $ SearchArticles
    { sort: [ by @"magazineIssue.pageNumber" Asc, by @"writtenAt.instant" Desc ]
    , filter: Just $ (ArticleMagazineIssueHasSlug slug) && ArticleHasMagazineIssuePageNumber
    , expectation: QuickNothingBetterThanSlowerSomething
    , limit: BoundedLimit 100
    , after: Nothing
    , needs: bandArticleNeeds { lead = Needed { fallbackToContentExcerpt: Just { cutStrategy: OnSentenceEnd { min: 200, max: 300, suffix: OnlyOnHardSentenceCut Default }, newlineReplacement: Just " ¶ " }, untagHtml: { whitelist: LeadClean.defaultUntagWhitelist, blacklistInWhitelist: Tags [] } } { isFallback: Needed ι ι } }
    }

  case res of
    Success { articles } | Array.length articles == 0 -> do
      res2 <- query $ SearchArticles
        { sort: [ by @"magazineIssue.pageNumber" Asc, by @"writtenAt.instant" Desc ]
        , filter: Just $ (ArticleMagazineIssueHasSlug slug)
        , expectation: QuickNothingBetterThanSlowerSomething
        , limit: BoundedLimit 100
        , after: Nothing
        , needs: bandArticleNeeds { lead = Needed { fallbackToContentExcerpt: Just { cutStrategy: OnSentenceEnd { min: 200, max: 300, suffix: OnlyOnHardSentenceCut Default }, newlineReplacement: Just " ¶ " }, untagHtml: { whitelist: LeadClean.defaultUntagWhitelist, blacklistInWhitelist: Tags [] } } { isFallback: Needed ι ι } }
        }
      modify_ (_magazine ◁ _articles .~ res2)
      case res2 of
        Success { articles: arts2 } -> ø $ fork $ cacheMagazineArticles arts2
        _ -> ηι
    _ -> do
      modify_ (_magazine ◁ _articles .~ res)
      case res of
        Success { articles } -> ø $ fork $ cacheMagazineArticles articles
        _ -> ηι

cacheMagazineArticles :: Array Article -> MenuM Ɩ
cacheMagazineArticles articles = for_ articles \art -> do
  let
    slugVal = extractRequiredCacheValue art.slug
    titleVal = sanitizeHtml (unwrap (extractRequiredCacheValue art.title))

    bookAuthors = case extractRequiredCacheValue art.books of
      QueryResult.Unfolded bks -> bks >>= \b -> extractRequiredCacheValue b.authors <#> \a -> sanitizeHtml (untagAll false (unwrap a.name))
      _ -> []

    articleAuthorTxt = extractOptionalCacheValue art.author <#> \a ->
      { id: Util.Type.String.ToString.toString (extractRequiredCacheValue a.id), name: sanitizeHtml (untagAll false (unwrap (extractRequiredCacheValue a.name))) }

    leadVal =
      let
        l = extractRequiredCacheValue art.lead
      in
        { lead: extractOptionalCacheValue l.lead <#> \h -> sanitizeHtml (unwrap h)
        , isFallback: extractRequiredCacheValue l.isFallback
        }

    illustrations = extractRequiredCacheValue art.illustrations

    firstIll = Array.head illustrations

    imageVal = case firstIll of
      Just ill ->
        let
          isFb = extractRequiredCacheValue ill.isFallback
          illCaption = extractOptionalCacheValue ill.caption <#> \cap -> sanitizeHtml (unwrap cap)
          image = extractRequiredCacheValue ill.image
          dims = extractRequiredCacheValue image.dimensions
          w = extractRequiredCacheValue dims.width
          h = extractRequiredCacheValue dims.height
          src = extractRequiredCacheValue image.src
        in
          Just { src: src, dimensions: { width: w, height: h }, caption: illCaption, isFallback: isFb }
      Nothing -> Nothing

  when (Util.Type.String.ToString.toString slugVal /= "") $ putArticleCache (Util.Type.String.ToString.toString slugVal)
    { slug: slugVal
    , title: titleVal
    , bookAuthors: bookAuthors
    , author: articleAuthorTxt
    , lead: leadVal
    , illustration: imageVal
    }
