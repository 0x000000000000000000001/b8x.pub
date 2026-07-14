module Core.Feat.Review.Message.Query.GetFrontPage.Query where

import Proem hiding ((&&))

import Config.PublicConfig (READER_PUBLIC_CONFIG, askPublicConfig)
import Control.Alt ((<|>))
import Core.Event.EventStore (EVENT_STORE)
import Core.Exception.Index (EXCEPT_LOGIC)
import Core.Message.Query.Handle (build)
import Core.Message.Query.Payload (Fold(..)) as Payload
import Core.Message.Query.Payload (Need(..))
import Core.Message.Query.Query (class IsQuery, defaultCached)
import Core.Message.Query.Result (Fold(..)) as Result
import Core.Message.Query.Result (Return(..))
import Core.Feat.Review.Message.Query.GetFrontPage.Field.Needs (Needs)
import Core.Feat.Review.Message.Query.GetFrontPage.Payload (Fields, Payload)
import Core.Feat.Review.Message.Query.GetFrontPage.Projection.Projection (Article(..), ArticleFilter(..), FrontPage(..), FrontPageArticles, emptyFrontPage, findArticles, findArticlesByIds, findFrontPage, GET_FRONT_PAGE_ARTICLE_PROJECTION_READ)
import Core.Feat.Review.Message.Query.GetFrontPage.Result.Article.Article as ResultArticle
import Core.Feat.Review.Message.Query.GetFrontPage.Result.Result (Result)
import Core.Feat.Review.Message.Query.GetFrontPage.State (State)
import Core.Mod.Article.Content.Message.Query.Build (buildContent)
import Core.Mod.Article.Id.Id (ArticleId)
import Core.Mod.Article.Illustrations.Message.Query.Build (buildIllustrations, buildIllustration)
import Core.Mod.Article.Lead.Message.Query.Build (buildLead)
import Core.Mod.Article.Message.Query.Opt (ArticleOpt, ArticleInnerNeeds)
import Core.Mod.Article.Title.Message.Query.Build (buildTitle)
import Core.Mod.Article.Notes.Message.Query.Build (buildNotes)
import Core.Mod.Author.Message.Query.Build (buildAuthor)
import Core.Mod.Book.Message.Query.Build (buildBooks, buildBook)
import Core.Mod.Projection.Finder.Expectation.Expectation (Expectation(..))
import Core.Mod.Projection.Finder.Filter (Limit(..))
import Core.Mod.Projection.Finder.Finder (getReadModelHash, defaultFindOpt)
import Core.Mod.Projection.Finder.Sort (SortDirection(..))
import Core.Mod.Projection.Finder.Sort as Sort
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Array (catMaybes, filter, foldl, head)
import Data.Generic.Rep (class Generic)
import Data.Map (Map)
import Data.Map as Map
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype, unwrap)
import Data.Set (Set)
import Data.Set as Set
import Data.Tuple (Tuple(..))
import Run (Run)
import Type.Row (type (+))
import Util.Type.Random (class Random)
import Util.Type.Type (class Reflect, reflectConstructorName)

newtype GetFrontPage = GetFrontPage Payload

derive instance Newtype GetFrontPage _
derive instance Generic GetFrontPage _
derive newtype instance Random GetFrontPage
derive newtype instance WriteForeign GetFrontPage
derive newtype instance ReadForeign GetFrontPage

instance Reflect GetFrontPage where
  reflectName = reflectConstructorName @GetFrontPage

instance IsQuery GetFrontPage State Fields Payload Result where
  description = "Get the front page"

  cacheStrategy _ = do
    hash <- getReadModelHash @Article Nothing
    η $ defaultCached hash

  handle (GetFrontPage { theme, needs }) = do
    config <- askPublicConfig

    mFp <- findFrontPage theme

    let
      FrontPage { articles: articles@{ center, topLeft, topRight, bottomLeft, bottomRight } } = mFp ??⇒ emptyFrontPage
      preAssignedIds = catMaybes [ center, topLeft, topRight, bottomLeft, bottomRight ]

    fetchedArticles <- findArticlesByIds preAssignedIds

    let
      foundIds = Set.fromFoldable $ fetchedArticles <#> \(Article a) -> a.id
      startingGrid = normalizeArticles articles foundIds

    fallbackLandscapeArticles <- fetchFallbackArticles startingGrid needs true

    let
      fallbackLandscapeArticleIds = fallbackLandscapeArticles <#> (unwrap ▷ _.id)
      gridResolvedWithLandscape = resolveGrid startingGrid fallbackLandscapeArticleIds

    fallbackArticles <- fetchFallbackArticles gridResolvedWithLandscape needs false

    let
      fallbackArticleIds = fallbackArticles <#> (unwrap ▷ _.id)
      grid = resolveGrid gridResolvedWithLandscape fallbackArticleIds
      allArticles = fetchedArticles <> fallbackLandscapeArticles <> fallbackArticles
      articleMap = Map.fromFoldable $ allArticles <#> \article@(Article a) -> Tuple a.id article

      urlBase = config.objectStorage.urlBase
      build = buildResponseArticle urlBase articleMap

    η
      { topLeft: build needs.topLeft grid.topLeft
      , topRight: build needs.topRight grid.topRight
      , center: build needs.center grid.center
      , bottomLeft: build needs.bottomLeft grid.bottomLeft
      , bottomRight: build needs.bottomRight grid.bottomRight
      }
    where
    normalizeArticles :: FrontPageArticles -> Set ArticleId -> FrontPageArticles
    normalizeArticles { center, topLeft, topRight, bottomLeft, bottomRight } foundIds =
      let
        normalizePos pos = case pos of
          Just p | Set.member p foundIds -> Just p
          _ -> Nothing
      in
        { center: normalizePos center
        , topLeft: normalizePos topLeft
        , topRight: normalizePos topRight
        , bottomLeft: normalizePos bottomLeft
        , bottomRight: normalizePos bottomRight
        }

    fetchFallbackArticles
      :: ∀ fx
       . FrontPageArticles
      -> Needs
      -> Boolean
      -> Run
           (EVENT_STORE + EXCEPT_LOGIC + GET_FRONT_PAGE_ARTICLE_PROJECTION_READ + READER_PUBLIC_CONFIG + fx)
           (Array Article)
    fetchFallbackArticles { center, topLeft, topRight, bottomLeft, bottomRight } needs' landscape =
      let
        count pos posNeed = case pos, posNeed of
          Nothing, Needed _ _ -> 1
          _, _ -> 0

        missingCount =
          count center needs'.center
            + count topLeft needs'.topLeft
            + count topRight needs'.topRight
            + count bottomLeft needs'.bottomLeft
            + count bottomRight needs'.bottomRight

        gridList = catMaybes [ center, topLeft, topRight, bottomLeft, bottomRight ]

        initialPredicate = ArticleHasAtLeastOneIllustration (not landscape)

        themePredicate = case theme of
          Nothing -> initialPredicate
          Just t -> ArticleAnd { left: initialPredicate, right: ArticleHasTheme t }

        filter = Just $ foldl (\left right -> ArticleAnd { left, right }) themePredicate (ArticleHasNotId <$> gridList)
      in
        missingCount == 0 ? η []
          ↔ findArticles (defaultFindOpt { filter = filter, limit = Finite missingCount, expectation = QuickNothingBetterThanSlowerSomething, sort = [ Sort.by @"writtenAt" Desc ] })
          <#> _.items

    resolveGrid :: FrontPageArticles -> Array ArticleId -> FrontPageArticles
    resolveGrid { center, topLeft, topRight, bottomLeft, bottomRight } fallbackArticleIds =
      let
        center' = center <|> head fallbackArticleIds
        fallbackArticleIds2 = fallbackArticleIds # filter (Just ▷ (_ /= center'))
        topLeft' = topLeft <|> head fallbackArticleIds2
        fallbackArticleIds3 = fallbackArticleIds2 # filter (Just ▷ (_ /= topLeft'))
        topRight' = topRight <|> head fallbackArticleIds3
        fallbackArticleIds4 = fallbackArticleIds3 # filter (Just ▷ (_ /= topRight'))
        bottomLeft' = bottomLeft <|> head fallbackArticleIds4
        fallbackArticleIds5 = fallbackArticleIds4 # filter (Just ▷ (_ /= bottomLeft'))
        bottomRight' = bottomRight <|> head fallbackArticleIds5
      in
        { center: center'
        , topLeft: topLeft'
        , topRight: topRight'
        , bottomLeft: bottomLeft'
        , bottomRight: bottomRight'
        }

    buildResponseArticle
      :: String
      -> Map ArticleId Article
      -> Need ArticleOpt ArticleInnerNeeds
      -> Maybe ArticleId
      -> Return ResultArticle.Article
    buildResponseArticle urlBase articleMap need mId = case need of
      NotNeeded -> NotGivenBecauseNotNeeded
      Needed Payload.Folded Payload.Folded -> case mId of
        Nothing -> NotGivenBecauseNotFound
        Just id -> Given (Result.Folded (Just id))
      Needed (Payload.Unfolded _) (Payload.Unfolded innerNeeds_) -> case mId >>= \id -> Map.lookup id articleMap of
        Nothing -> NotGivenBecauseNotFound
        Just (Article a) -> Given $ Result.Unfolded $ Just
          { id: build innerNeeds_.id a.id
          , legacyId: build innerNeeds_.legacyId a.legacyId
          , slug: build innerNeeds_.slug a.slug
          , title: buildTitle innerNeeds_.title a.title
          , content: buildContent innerNeeds_.content a.content
          , theme: build innerNeeds_.theme a.theme
          , books: buildBooks innerNeeds_.books a.books (buildBook urlBase)
          , author: buildAuthor urlBase innerNeeds_.author a.author
          , illustrations: buildIllustrations innerNeeds_.illustrations a.illustrations a.books (buildIllustration urlBase)
          , lead: buildLead innerNeeds_.lead a.lead a.content
          , notes: buildNotes innerNeeds_.notes a.notes
          }
      Needed _ _ -> case mId of
        Nothing -> NotGivenBecauseNotFound
        Just id -> Given (Result.Folded (Just id))
