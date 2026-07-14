module Inter.Ui.Router.Menu.HandleAction.FetchResults (fetchResults) where

import Core.Mod.Article.Content.Excerpt.CutStrategy (CutStrategy(..), Suffix(..), SuffixValue(..))
import Proem hiding (top, div)

import Core.Message.Query.Payload (Need(..), Fold(..))
import Core.Message.Query.Result (Return(..))
import Core.Mod.Article.Content.Message.Query.Opt (ExcerptOpt(..))
import Core.Mod.Book.Cover.Message.Query.Opt (defaultCoverOpt)
import Core.Feat.Review.Message.Query.SearchArticles.Field.Needs (defaultNeeds)
import Core.Feat.Review.Message.Query.SearchArticles.Query (SearchArticles(..))
import Core.Feat.Review.Message.Query.SearchArticles.Result (Article)
import Core.Mod.Article.Content.Excerpt.Excerpt as ContentExcerpt
import Core.Mod.Article.Lead.Clean as LeadClean
import Core.Mod.Article.Title.Clean as TitleClean
import Core.Feat.Review.Message.Query.SearchArticles.Projection.Projection as ArticleFilter
import Core.Mod.Projection.Finder.BoundedLimit.BoundedLimit as BoundedLimit
import Core.Mod.Projection.Finder.Expectation.Expectation (Expectation(..))
import Core.Mod.Projection.Finder.Sort as Sort
import Data.Array as Array
import Data.Lens ((.~), (^.))
import Data.Maybe (Maybe(..))
import Data.String as String
import Halogen (fork, gets, kill, modify_)
import Inter.Ui.Remote (query)
import Inter.Ui.Router.Menu.Core.Search.Results.Item.Core.TextWithMatchingWords.TextWithMatchingWords (normalizeWord)
import Inter.Ui.Router.Menu.Core.Search.Results.Item.Item (item)
import Inter.Ui.Router.Menu.Core.Search.Results.Item.Thumb.Thumb (extractThumb)
import Inter.Ui.Router.Menu.Core.Search.Results.Style.Style as Results
import Inter.Ui.Router.Menu.Type.MenuM (MenuM)
import Inter.Ui.Router.Menu.Type.State.Search (_authorFilter, _controlled, _forkId, _results)
import Inter.Ui.Router.Menu.Type.State.State (_search)
import Inter.Ui.Type.ControlledState (ControlledState(..))
import Network.RemoteData (RemoteData(..))
import Util.Html.Clean.Clean (TagList(..), untagAll)
import Util.Html.Dom.Dom (scrollElementToTopByClass)
import Util.Type.String.String (Token(..), tokenize)
import Inter.Ui.Capability.ArticleCache.Trans (putArticleCache)
import Data.Foldable (for_)
import Core.Message.Query.Result as QueryResult
import Util.Type.String.ToString as Util.Type.String.ToString
import Util.Html.Clean.Render.Render (sanitizeHtml)
import Data.Newtype (unwrap)
import Inter.Ui.Capability.ArticleCache.ArticleCache (extractRequiredCacheValue, extractOptionalCacheValue)

fetchResults :: MenuM Ɩ
fetchResults = do
  controlledState <- gets (_ ^. _search ◁ _controlled)

  let
    value = case controlledState of
      Controlled c -> c.query
      Uncontrolled c -> c.query

  mSearchForkId <- gets _.search.forkId

  case mSearchForkId of
    Just fid -> kill fid
    Nothing -> ηι

  scrollElementToTopByClass Results.staticClass

  authorFilterState <- gets (_ ^. _search ◁ _authorFilter)

  let
    articleAuthorTokens = case authorFilterState of
      Just { name, ofBook: false } ->
        tokenize (untagAll false (unwrap name))
          # Array.mapMaybe
              ( case _ of
                  Word w -> Just (normalizeWord w)
                  Separator _ -> Nothing
              )
      _ -> []

    bookAuthorTokens = case authorFilterState of
      Just { name, ofBook: true } ->
        tokenize (untagAll false (unwrap name))
          # Array.mapMaybe
              ( case _ of
                  Word w -> Just (normalizeWord w)
                  Separator _ -> Nothing
              )
      _ -> []

    excerptSearches =
      tokenize value
        # Array.mapMaybe
            ( case _ of
                Word w -> Just (normalizeWord w)
                Separator _ -> Nothing
            )

    normSearches = { excerptSearches, articleAuthorTokens, bookAuthorTokens }
    needed = Needed ι ι
    needs = defaultNeeds
      { id = needed
      , title = Needed
          { untagHtml: { whitelist: TitleClean.defaultUntagWhitelist
                  , blacklistInWhitelist: Tags []
                  }
          }
          ι
      , lead =
          Needed
            { fallbackToContentExcerpt: Just { cutStrategy: OnSentenceEnd { min: 200, max: 300, suffix: OnlyOnHardSentenceCut Default }, newlineReplacement: Just " ¶ " }
            , untagHtml: { whitelist: LeadClean.defaultUntagWhitelist
                    , blacklistInWhitelist: Tags []
                    }
            }
            { isFallback: Needed ι ι
            }
      , content =
          Needed
            { excerpt: YesBestMatchingWords { newlineReplacement: Just " ¶ ", words: excerptSearches }
            , untagHtml: { whitelist: ContentExcerpt.defaultUntagWhitelist
                    , blacklistInWhitelist: Tags []
                    }
            }
            ι
      , author = Needed ι { id: Needed ι ι, name: Needed ι ι, biography: NotNeeded, portrait: NotNeeded }
      , books = Needed (Unfolded ι) $ Unfolded
          { id: NotNeeded
          , name: Needed ι ι
          , year: NotNeeded
          , cover: Needed defaultCoverOpt { src: Needed { absolute: true } ι, dimensions: NotNeeded }
          , authors: needed
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
      , slug = needed
      }
    pageSize = 12

  fid <- fork $ do
    let
      baseFilter = case authorFilterState of
        Just { id: authorId, ofBook: true } ->
          let
            f = ArticleFilter.ArticleBookAuthorHasId (authorId)
          in
            if String.trim value == "" then f else (ArticleFilter.ArticleMatches { query: value, weight: 1.0 }) && f
        Just { id: authorId, ofBook: false } ->
          let
            f = ArticleFilter.ArticleAuthorHasId (authorId)
          in
            if String.trim value == "" then f else (ArticleFilter.ArticleMatches { query: value, weight: 1.0 }) && f
        _ -> ArticleFilter.ArticleMatches { query: value, weight: 1.0 }

      toHtml menuId a =
        { html: item menuId (extractThumb a) normSearches a
        , id: case a.id of
            Given id -> Just id
            _ -> Nothing
        }

      buildQuery expectation filter limit = SearchArticles
        { sort: []
        , filter: Just filter
        , limit: BoundedLimit.make limit
        , expectation
        , after: Nothing
        , needs
        }

    res1 <- query (buildQuery QuickNothingBetterThanSlowerSomething baseFilter pageSize)

    oldResults <- gets (_.search ▷ _.results)
    let
      oldItemsArray = case oldResults of
        Success arr -> arr
        _ -> []
      mergeToOld newItems =
        let
          newIds = Array.mapMaybe _.id newItems
          filteredOld = Array.filter
            ( \old -> case old.id of
                Just oid -> not $ Array.elem oid newIds
                Nothing -> true
            )
            oldItemsArray
          remainingNeeded = pageSize - Array.length newItems
          keptOld = Array.take remainingNeeded filteredOld
        in
          newItems <> keptOld

    menuId <- gets _.id

    case res1 of
      Success { articles } -> do
        ø $ fork $ cacheSearchArticles articles
      _ -> ηι

    let
      res1Items = case res1 of
        Success { articles } -> articles <#> toHtml menuId
        _ -> []

    modify_ $ (_search ◁ _results .~ Success (mergeToOld res1Items))

    case res1 of
      Success { articles: articles1 } | Array.length articles1 < pageSize -> do
        let
          res1Ids = Array.mapMaybe
            ( \a -> case a.id of
                Given id -> Just id
                _ -> Nothing
            )
            articles1
          filter2 = Array.foldl (\acc id -> acc && (ArticleFilter.ArticleHasNotId id)) baseFilter res1Ids
          limit2 = pageSize - Array.length articles1

        res2 <- query (buildQuery SlowerSomethingBetterThanQuickNothing filter2 limit2)
        case res2 of
          Success { articles: articles2 } -> do
            ø $ fork $ cacheSearchArticles articles2
            let
              res2Items = articles2 <#> toHtml menuId
              res12Items = res1Items <> res2Items

            modify_ $ (_search ◁ _results .~ Success (mergeToOld res12Items))

            if Array.length articles2 < limit2 then do
              let
                limit3 = limit2 - Array.length articles2
                res12Ids = Array.mapMaybe
                  ( \a -> case a.id of
                      Given id -> Just id
                      _ -> Nothing
                  )
                  (articles1 <> articles2)
                exclusionFilter = case Array.uncons res12Ids of
                  Nothing -> Nothing
                  Just { head, tail } -> Just $ Array.foldl (\acc id -> acc && (ArticleFilter.ArticleHasNotId id)) (ArticleFilter.ArticleHasNotId head) tail

                filter3 = case authorFilterState of
                  Just { id: authorId } ->
                    let
                      authFilter = ArticleFilter.ArticleAuthorHasId (authorId)
                    in
                      case exclusionFilter of
                        Just ex -> Just (authFilter && ex)
                        Nothing -> Just authFilter
                  Nothing -> exclusionFilter

              res3 <- query $ SearchArticles
                { sort: [ Sort.by @"writtenAt.instant" Sort.Desc ]
                , filter: filter3
                , limit: BoundedLimit.make limit3
                , expectation: SlowerSomethingBetterThanQuickNothing
                , after: Nothing
                , needs
                }
              case res3 of
                Success { articles: articles3 } -> do
                  ø $ fork $ cacheSearchArticles articles3
                  let res3Items = articles3 <#> toHtml menuId
                  modify_ $ (_search ◁ _results .~ Success (res12Items <> res3Items))
                _ -> do
                  modify_ $ (_search ◁ _results .~ Success res12Items)
            else do
              modify_ $ (_search ◁ _results .~ Success res12Items)
          _ ->
            modify_ $ (_search ◁ _results .~ Success res1Items)
      _ ->
        modify_ $ (_search ◁ _results .~ Success res1Items)

    modify_ (_search ◁ _forkId .~ Nothing)

  modify_ (_search ◁ _forkId .~ Just fid)

cacheSearchArticles :: Array Article -> MenuM Ɩ
cacheSearchArticles articles = for_ articles \art -> do
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
