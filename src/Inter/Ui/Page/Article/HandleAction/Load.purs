module Inter.Ui.Page.Article.HandleAction.Load
  ( load
  ) where

import Core.Mod.Article.Content.Excerpt.CutStrategy (CutStrategy(..), Suffix(..), SuffixValue(..))
import Proem

import Core.Feat.Review.Message.Command.TrackArticleRead.Command (TrackArticleRead(..))
import Core.Feat.Review.Message.Query.GetArticle.Field.Needs (defaultNeeds)
import Core.Feat.Review.Message.Query.GetArticle.Query (GetArticle(..))
import Core.Feat.Review.Message.Query.SearchArticles.Field.Needs as SearchNeeds
import Core.Feat.Review.Message.Query.SearchArticles.Query (SearchArticles(..))
import Core.Message.Query.Payload (Fold(..), Need(..))
import Core.Message.Query.Result (Return(..))
import Core.Message.Query.Result as QueryResult
import Core.Mod.Article.Content.Message.Query.Opt (defaultContentOpt)
import Core.Mod.Article.Identifier.ArticleIdentifier (ArticleIdentifier(..))
import Core.Mod.Article.Lead.Clean as LeadClean
import Core.Feat.Review.Message.Query.SearchArticles.Projection.Projection as ArticleFilter
import Core.Mod.Article.Title.Clean as TitleClean
import Core.Mod.Book.Cover.Message.Query.Opt (defaultCoverOpt)
import Core.Mod.Projection.Finder.BoundedLimit.BoundedLimit as BoundedLimit
import Core.Mod.Projection.Finder.Expectation.Expectation (Expectation(..))
import Data.Array as Array
import Data.Lens ((.~))
import Data.Maybe (Maybe(..))
import Data.Traversable (traverse)
import Data.Tuple (Tuple(..), snd)
import Effect.Random (randomInt)
import Halogen (fork, gets, modify_, raise)
import Inter.Api.Social.Meta.Route.Article.Shared (buildMeta, makeQuery)
import Inter.Ui.Capability.ArticleCache.Trans (putArticleCache)
import Inter.Ui.Page.Article.Type (ArticleM, Output(..), _article, _relatedArticles, _issueArticles)
import Inter.Ui.Remote (query, queryUpdateMeta, command_)
import Network.RemoteData (RemoteData(..))
import Util.Html.Clean.Clean (TagList(..), untagAll)
import Util.Type.String.ToString (toString)
import Util.Html.Clean.Render.Render (SanitizedHtmlString, sanitizeHtml)
import Util.Html.Clean.Render.WpAutop.WpAutop (wpAutop)
import Core.Mod.Html.Html (NonEmptyHtml)
import Data.Newtype (unwrap)
import Core.Feat.Review.Message.Query.GetArticle.Result (Article) as GetArticle
import Core.Feat.Review.Message.Query.SearchArticles.Result (Article) as Search
import Inter.Ui.Type.Model (UiArticle, UiSearchArticle)
import Inter.Ui.Capability.ArticleCache.ArticleCache (extractRequiredCacheValue, extractOptionalCacheValue)

cleanNonEmpty :: NonEmptyHtml -> SanitizedHtmlString
cleanNonEmpty c = sanitizeHtml (unwrap c)

cleanNonEmptyStripTags :: NonEmptyHtml -> SanitizedHtmlString
cleanNonEmptyStripTags c = sanitizeHtml (untagAll false (unwrap c))

cleanWpNonEmpty :: NonEmptyHtml -> SanitizedHtmlString
cleanWpNonEmpty c = sanitizeHtml (wpAutop false (unwrap c))

toUiArticle :: GetArticle.Article -> UiArticle
toUiArticle art =
  { id: art.id
  , legacyId: art.legacyId
  , title: art.title <#> cleanNonEmpty
  , lead: art.lead <#> \l -> { lead: l.lead <#> map cleanNonEmpty, isFallback: l.isFallback }
  , content: art.content <#> cleanWpNonEmpty
  , notes: art.notes <#> map cleanWpNonEmpty
  , sources: art.sources <#> map cleanWpNonEmpty
  , theme: art.theme
  , author: art.author <#> map (\a -> { id: a.id, name: a.name <#> cleanNonEmptyStripTags, biography: a.biography <#> map cleanWpNonEmpty, portrait: a.portrait })
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
  , magazineIssue: art.magazineIssue
  }

toUiSearchArticle :: Search.Article -> UiSearchArticle
toUiSearchArticle art =
  { id: art.id
  , legacyId: art.legacyId
  , title: art.title <#> cleanNonEmpty
  , lead: art.lead <#> \l -> { lead: l.lead <#> map cleanNonEmpty, isFallback: l.isFallback }
  , content: art.content <#> cleanWpNonEmpty
  , notes: art.notes <#> map cleanWpNonEmpty
  , sources: art.sources <#> map cleanWpNonEmpty
  , theme: art.theme
  , author: art.author <#> map (\a -> { id: a.id, name: a.name <#> cleanNonEmptyStripTags, biography: a.biography <#> map cleanWpNonEmpty, portrait: a.portrait })
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

load :: ArticleM Ɩ
load = do
  state <- gets identity
  let slug = state.input.slug
  do
    ø $ fork $ queryUpdateMeta (map (buildMeta Nothing)) (makeQuery slug)

    modify_ (_article .~ Loading)

    res <- query $ GetArticle
      { identifier: Slug slug
      , needs: defaultNeeds
          { id = Needed ι ι
          , title = Needed
              { untagHtml:
                  { whitelist: TitleClean.defaultUntagWhitelist
                  , blacklistInWhitelist: Tags []
                  }
              }
              ι
          , lead =
              Needed
                { fallbackToContentExcerpt: Just { cutStrategy: OnSentenceEnd { min: 200, max: 300, suffix: OnlyOnHardSentenceCut Default }, newlineReplacement: Just " " }
                , untagHtml:
                    { whitelist: LeadClean.defaultUntagWhitelist
                    , blacklistInWhitelist: Tags []
                    }
                }
                { isFallback: Needed ι ι
                }

          , content = Needed defaultContentOpt ι
          , notes = Needed ι ι
          , sources = Needed ι ι
          , author = Needed ι
              { id: Needed ι ι
              , name: Needed ι ι
              , biography: Needed ι ι
              , portrait: Needed ι
                  { src: Needed { absolute: true } ι
                  , dimensions: Needed ι { width: Needed ι ι, height: Needed ι ι }
                  }
              }
          , books = Needed (Unfolded ι) $ Unfolded
              { id: NotNeeded
              , name: Needed ι ι
              , year: Needed ι ι
              , cover: Needed defaultCoverOpt { src: Needed { absolute: true } ι, dimensions: NotNeeded }
              , authors: Needed ι ι
              , editor: Needed ι ι
              }
          , illustrations = Needed
              { priorizeRatio: Nothing
              , fallbackToBookCovers: false
              }
              { image: Needed ι
                  { src: Needed { absolute: true } ι
                  , dimensions: Needed ι { width: Needed ι ι, height: Needed ι ι }
                  }
              , caption: Needed ι ι
              , isFallback: Needed ι ι
              }
          , magazineIssue = Needed ι ι
          }
      }

    let cleanedRes = map (map toUiArticle) res
    modify_ (_article .~ cleanedRes)

    case cleanedRes of
      Success (Just art) -> do
        let
          slugStr = toString slug

          titleVal = extractRequiredCacheValue art.title

          titleStr = unwrap titleVal

          articleAuthorTxt = extractOptionalCacheValue art.author <#> \a ->
            { id: toString (extractRequiredCacheValue a.id), name: extractRequiredCacheValue a.name }

          bookAuthors = case extractRequiredCacheValue art.books of
            QueryResult.Unfolded bks -> bks >>= \b -> extractRequiredCacheValue b.authors <#> \a -> a.name
            _ -> []

          leadVal =
            let
              l = extractRequiredCacheValue art.lead
            in
              { lead: extractOptionalCacheValue l.lead, isFallback: extractRequiredCacheValue l.isFallback }

          illustrations = extractRequiredCacheValue art.illustrations

          firstIll = Array.head illustrations

          imageVal = case firstIll of
            Nothing -> Nothing
            Just ill ->
              let
                image = extractRequiredCacheValue ill.image
                dims = extractRequiredCacheValue image.dimensions
                w = extractRequiredCacheValue dims.width
                h = extractRequiredCacheValue dims.height
                src = extractRequiredCacheValue image.src
                isFallback = extractRequiredCacheValue ill.isFallback
                caption = extractOptionalCacheValue ill.caption
              in
                Just { src, dimensions: { width: w, height: h }, caption, isFallback }

        when (slugStr /= "") $ putArticleCache slugStr
          { slug: slug
          , title: titleVal
          , bookAuthors: bookAuthors
          , author: articleAuthorTxt
          , lead: leadVal
          , illustration: imageVal
          }

        let
          resId = case art.id of
            Given i -> Just i
            _ -> Nothing

        case resId of
          Just id | titleStr /= "" -> do
            ø $ fork $ command_ $ TrackArticleRead { id }

            modify_ (_relatedArticles .~ Loading)
            let
              filter =
                (ArticleFilter.ArticleMatches { query: titleStr, weight: 3.0 })
                  && (ArticleFilter.ArticleHasAtLeastOneIllustration true)
                  && (ArticleFilter.ArticleHasNotId id)

              needs = SearchNeeds.defaultNeeds
                { id = Needed ι ι
                , title = Needed
                    { untagHtml:
                        { whitelist: TitleClean.defaultUntagWhitelist
                        , blacklistInWhitelist: Tags []
                        }
                    }
                    ι
                , lead =
                    Needed
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
                    , cover: NotNeeded
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
                , slug = Needed ι ι
                }

            ø $ fork $ do
              relRes <- query $ SearchArticles
                { sort: []
                , filter: Just filter
                , limit: BoundedLimit.make 12
                , expectation: SlowerSomethingBetterThanQuickNothing
                , after: Nothing
                , needs
                }
              case relRes of
                Success { articles } -> modify_ (_relatedArticles .~ Success (map toUiSearchArticle articles))
                _ -> modify_ (_relatedArticles .~ Failure "Could not load related articles")

            let
              mMagIssue = case art.magazineIssue of
                Given (Just mi) -> Just mi
                _ -> Nothing

            case mMagIssue of
              Just mi -> do
                modify_ (_issueArticles .~ Loading)
                ø $ fork $ do
                  let
                    issueFilter = (ArticleFilter.ArticleMagazineIssueHasId (unwrap mi).issue.id) && (ArticleFilter.ArticleHasAtLeastOneIllustration true) && (ArticleFilter.ArticleHasNotId id)
                  issRes <- query $ SearchArticles
                    { sort: []
                    , filter: Just issueFilter
                    , limit: BoundedLimit.make 100
                    , expectation: SlowerSomethingBetterThanQuickNothing
                    , after: Nothing
                    , needs
                    }
                  case issRes of
                    Success { articles } -> do
                      shuffled <- ʌ $ do
                        withRands <- traverse
                          ( \a -> do
                              r <- randomInt 0 1000000
                              pure (Tuple r a)
                          )
                          articles
                        pure $ map snd $ Array.sortBy (\(Tuple r1 _) (Tuple r2 _) -> compare r1 r2) withRands
                      modify_ (_issueArticles .~ Success (map toUiSearchArticle (Array.take 12 shuffled)))
                    _ -> modify_ (_issueArticles .~ Failure "Could not load issue articles")
              Nothing -> modify_ (_issueArticles .~ Success [])
          _ -> ηι
      Success Nothing -> raise ArticleNotFound
      _ -> ηι
