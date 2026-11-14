module Inter.Ui.Router.Menu.HandleAction.FetchSearchResults (fetchSearchResults, nextSearchPage, previousSearchPage) where

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
import Inter.Ui.Router.Menu.Type.State.Search (_authorFilter, _controlled, _forkId, _pagination, _results, _currentPageIndex, PaginationState(..))
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

fetchSearchResults :: MenuM Ɩ
fetchSearchResults = do
  modify_ (_search ◁ _pagination .~ FetchingFirstPage)
  modify_ (_search ◁ _currentPageIndex .~ 0)

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
      , writtenAt = needed
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

    menuId <- gets _.id

    case res1 of
      Success { articles } -> do
        ø $ fork $ cacheSearchArticles articles
      _ -> ηι

    let
      res1Items = case res1 of
        Success { articles } -> articles <#> toHtml menuId
        _ -> []

    modify_ $ (_search ◁ _results .~ Success [res1Items])

    let
      ctx1 = { filter: Just baseFilter, expectation: QuickNothingBetterThanSlowerSomething }
    case res1 of
      Success { articles: articles1, hasNextPage: _ } | Array.length articles1 < pageSize -> do
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

            modify_ $ (_search ◁ _results .~ Success [res12Items])

            let
              ctx2 = { filter: Just filter2, expectation: SlowerSomethingBetterThanQuickNothing }
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
                { sort: []
                , filter: filter3
                , limit: BoundedLimit.make limit3
                , expectation: SlowerSomethingBetterThanQuickNothing
                , after: Nothing
                , needs
                }
              let filter3Ctx = { filter: filter3, expectation: SlowerSomethingBetterThanQuickNothing }
              case res3 of
                Success { articles: articles3, hasNextPage: hasNextPage3 } -> do
                  ø $ fork $ cacheSearchArticles articles3
                  let res3Items = articles3 <#> toHtml menuId
                  modify_ $ (_search ◁ _results .~ Success [res12Items <> res3Items])
                  modify_ $ (_search ◁ _pagination .~ Displaying { context: filter3Ctx, hasNextPage: hasNextPage3 })
                _ -> do
                  modify_ $ (_search ◁ _results .~ Success [res12Items])
                  modify_ $ (_search ◁ _pagination .~ Displaying { context: filter3Ctx, hasNextPage: false })
            else do
              modify_ $ (_search ◁ _results .~ Success [res12Items])
              case res2 of
                Success { hasNextPage: hasNextPage2 } -> do
                  modify_ $ (_search ◁ _pagination .~ Displaying { context: ctx2, hasNextPage: hasNextPage2 })
                _ -> modify_ $ (_search ◁ _pagination .~ Displaying { context: ctx2, hasNextPage: false })
          _ -> do
            modify_ $ (_search ◁ _results .~ Success [res1Items])
            modify_ $ (_search ◁ _pagination .~ Displaying { context: ctx1, hasNextPage: false })
      _ -> do
        modify_ $ (_search ◁ _results .~ Success [res1Items])
        case res1 of
          Success { hasNextPage: hasNextPage1 } -> do
            modify_ $ (_search ◁ _pagination .~ Displaying { context: ctx1, hasNextPage: hasNextPage1 })
          _ -> modify_ $ (_search ◁ _pagination .~ Displaying { context: ctx1, hasNextPage: false })

    modify_ (_search ◁ _forkId .~ Nothing)

  modify_ (_search ◁ _forkId .~ Just fid)

cacheSearchArticles :: Array Article -> MenuM Ɩ
cacheSearchArticles articles = for_ articles \art -> do
  let
    slugVal = extractRequiredCacheValue "art.slug" art.slug
    titleVal = sanitizeHtml (unwrap (extractRequiredCacheValue "art.title" art.title))

    bookAuthors = case extractRequiredCacheValue "art.books" art.books of
      QueryResult.Unfolded bks -> bks >>= \b -> extractRequiredCacheValue "b.authors" b.authors <#> \a -> sanitizeHtml (untagAll false (unwrap a.name))
      _ -> []

    articleAuthorTxt = extractOptionalCacheValue "art.author" art.author <#> \a ->
      { id: Util.Type.String.ToString.toString (extractRequiredCacheValue "a.id" a.id), name: sanitizeHtml (untagAll false (unwrap (extractRequiredCacheValue "a.name" a.name))) }

    leadVal =
      let
        l = extractRequiredCacheValue "art.lead" art.lead
      in
        { lead: extractOptionalCacheValue "l.lead" l.lead <#> \h -> sanitizeHtml (unwrap h)
        , isFallback: extractRequiredCacheValue "l.isFallback" l.isFallback
        }

    illustrations = extractRequiredCacheValue "art.illustrations" art.illustrations

    firstIll = Array.head illustrations

    imageVal = case firstIll of
      Just ill ->
        let
          isFb = extractRequiredCacheValue "ill.isFallback" ill.isFallback
          illCaption = extractOptionalCacheValue "ill.caption" ill.caption <#> \cap -> sanitizeHtml (unwrap cap)
          image = extractRequiredCacheValue "ill.image" ill.image
          dims = extractRequiredCacheValue "image.dimensions" image.dimensions
          w = extractRequiredCacheValue "dims.width" dims.width
          h = extractRequiredCacheValue "dims.height" dims.height
          src = extractRequiredCacheValue "image.src" image.src
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
    , writtenAt: extractRequiredCacheValue "art.writtenAt" art.writtenAt
    }

nextSearchPage :: MenuM Ɩ
nextSearchPage = do
  paginationState <- gets (_.search ▷ _.pagination)
  currentPage <- gets (_.search ▷ _.currentPageIndex)
  resultsRes <- gets (_.search ▷ _.results)
  
  case paginationState of
    Displaying { context: ctx, hasNextPage: true } -> do
      case resultsRes of
        Success pages -> do
          if currentPage + 1 < Array.length pages then do
            -- The next page is already cached!
            modify_ (_search ◁ _currentPageIndex .~ currentPage + 1)
            scrollElementToTopByClass Results.staticClass
          else do
            -- We need to fetch the next page
            modify_ (_search ◁ _pagination .~ FetchingNextPage { context: ctx })
            
            menuId <- gets _.id
            controlledState <- gets (_ ^. _search ◁ _controlled)
            authorFilterState <- gets (_ ^. _search ◁ _authorFilter)
            
            let
              searchQuery = case controlledState of
                Controlled c -> c.query
                Uncontrolled c -> c.query
            
              pageSize = 12
              
              -- Get the last item of the last page
              lastPage = Array.last pages
              lastItem = lastPage >>= Array.last
              afterCursor = case lastItem of
                Just item -> item.id
                Nothing -> Nothing
                
              value = String.trim searchQuery
              
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
                    { untagHtml: { whitelist: TitleClean.defaultUntagWhitelist, blacklistInWhitelist: Tags [] }
                    }
                    ι
                , writtenAt = needed
                , lead = Needed
                    { fallbackToContentExcerpt: Just { cutStrategy: OnSentenceEnd { min: 200, max: 300, suffix: OnlyOnHardSentenceCut Default }, newlineReplacement: Just " ¶ " }
                    , untagHtml: { whitelist: LeadClean.defaultUntagWhitelist, blacklistInWhitelist: Tags [] }
                    }
                    { isFallback: Needed ι ι }
                , content = Needed
                    { excerpt: YesBestMatchingWords { newlineReplacement: Just " ¶ ", words: excerptSearches }
                    , untagHtml: { whitelist: ContentExcerpt.defaultUntagWhitelist, blacklistInWhitelist: Tags [] }
                    }
                    ι
                , author = Needed ι { id: Needed ι ι, name: Needed ι ι, biography: NotNeeded, portrait: NotNeeded }
                , books = Needed (Unfolded ι) $ Unfolded
                    { id: NotNeeded, name: Needed ι ι, year: NotNeeded, cover: Needed defaultCoverOpt { src: Needed { absolute: true } ι, dimensions: NotNeeded }, authors: needed, editor: Needed ι ι }
                , illustrations = Needed { priorizeRatio: Just (16.0 / 9.0), fallbackToBookCovers: true }
                    { image: Needed ι { src: Needed { absolute: true } ι, dimensions: Needed ι { width: Needed ι ι, height: Needed ι ι } }
                    , caption: Needed ι ι
                    , isFallback: Needed ι ι
                    }
                , slug = needed
                }
                
              toHtml mId a =
                { html: item mId (extractThumb a) normSearches a
                , id: case a.id of
                    Given id -> Just id
                    _ -> Nothing
                }
                
            res <- query $ SearchArticles
              { sort: []
              , filter: ctx.filter
              , limit: BoundedLimit.make pageSize
              , expectation: ctx.expectation
              , after: afterCursor
              , needs
              }
              
            case res of
              Success { articles, hasNextPage: newHasNextPage } -> do
                ø $ fork $ cacheSearchArticles articles
                let 
                  newItems = articles <#> toHtml menuId
                  mergedPages = Array.snoc pages newItems
                modify_ (_search ◁ _results .~ Success mergedPages)
                modify_ (_search ◁ _currentPageIndex .~ currentPage + 1)
                modify_ (_search ◁ _pagination .~ Displaying { context: ctx, hasNextPage: newHasNextPage })
                scrollElementToTopByClass Results.staticClass
              _ -> do
                modify_ (_search ◁ _pagination .~ Displaying { context: ctx, hasNextPage: true })
        _ -> ηι
    _ -> ηι

previousSearchPage :: MenuM Ɩ
previousSearchPage = do
  currentPage <- gets (_.search ▷ _.currentPageIndex)
  when (currentPage > 0) do
    modify_ (_search ◁ _currentPageIndex .~ currentPage - 1)
    scrollElementToTopByClass Results.staticClass
