module Inter.Ui.Page.Home.HandleAction.Load (load) where

import Core.Mod.Article.Content.Excerpt.CutStrategy (CutStrategy(..), Suffix(..), SuffixValue(..))
import Proem

import Core.Message.Query.Payload (Fold(..), Need(..))
import Core.Feat.Review.Message.Query.GetFrontPage.Query (GetFrontPage(..))
import Core.Mod.Article.Content.Message.Query.Opt (ExcerptOpt(..))
import Core.Feat.Review.Message.Query.GetFrontPage.Result.Article.Article as Article
import Core.Mod.Book.Cover.Message.Query.Opt (defaultCoverOpt)
import Core.Feat.Review.Message.Query.GetFrontPage.Result.Result as Result
import Core.Mod.Article.Content.Excerpt.Excerpt as ContentExcerpt
import Core.Mod.Article.Lead.Clean as LeadClean
import Core.Mod.Article.Title.Clean as TitleClean
import Data.Lens ((.~))
import Data.Maybe (Maybe(..))
import Data.Array as Array
import Halogen (fork, get, modify_)
import Halogen as Halogen
import Inter.Ui.Page.Home.Type (HomeM, _frontPage, _bandsForkId, _lastTriggeredFrontPageIds)
import Inter.Ui.Remote (queryModify')
import Core.Mod.Article.Id.Id (ArticleId)
import Network.RemoteData (RemoteData(..))
import Core.Message.Query.Result as QueryResult
import Effect.Ref as Ref
import Util.Html.Clean.Clean (TagList(..))
import Inter.Ui.Type.Model (UiFrontPageResult, UiSearchArticle)
import Inter.Ui.Page.Home.Util as HomeUtil
import Inter.Ui.Page.Home.HandleAction.LoadNews (loadNews)
import Inter.Ui.Page.Home.HandleAction.LoadMostRead (loadMostRead)
import Inter.Ui.Page.Home.HandleAction.LoadNewsletterArticles (loadNewsletterArticles)
import Inter.Ui.Page.Home.HandleAction.LoadQuote (loadQuote)

load :: HomeM Ɩ
load = do
  st <- get
  let
    theme = st.input.theme
    need = Needed (Unfolded ι) $ Unfolded
      { id: Needed ι ι
      , legacyId: NotNeeded
      , slug: Needed ι ι
      , title: Needed
          { untagHtml:
              { whitelist: TitleClean.defaultUntagWhitelist
              , blacklistInWhitelist: Tags []
              }
          }
          ι
      , lead: Needed
          { fallbackToContentExcerpt: Just { cutStrategy: OnSentenceEnd { min: 200, max: 300, suffix: OnlyOnHardSentenceCut Default }, newlineReplacement: Just " " }
          , untagHtml:
              { whitelist: LeadClean.defaultUntagWhitelist
              , blacklistInWhitelist: Tags []
              }
          }
          { isFallback: Needed ι ι
          }
      , notes: Needed ι ι
      , illustrations: Needed
          { priorizeRatio: Just 1.4
          , fallbackToBookCovers: true
          }
          { image: Needed ι
              { src: Needed { absolute: true } ι
              , dimensions: Needed ι
                  { width: Needed ι ι
                  , height: Needed ι ι
                  }
              }
          , caption: Needed ι ι
          , isFallback: Needed ι ι
          }
      , content:
          Needed
            { excerpt: No { newlineReplacement: Nothing }
            , untagHtml:
                { whitelist: ContentExcerpt.defaultUntagWhitelist
                , blacklistInWhitelist: Tags []
                }
            }
            ι
      , theme: Needed ι ι
      , books: Needed (Unfolded ι) $ Unfolded
          { id: Needed ι ι
          , name: Needed ι ι
          , year: NotNeeded
          , cover: Needed defaultCoverOpt { src: Needed { absolute: true } ι, dimensions: NotNeeded }
          , authors: Needed ι ι
          , editor: Needed ι ι
          }
      , author: Needed ι { id: Needed ι ι, name: Needed ι ι, biography: NotNeeded, portrait: NotNeeded }
      }

  ø $ fork $ do
    ø $ queryModify' toUiFrontPageResult (\_ -> triggerBands) _frontPage
      ( GetFrontPage
          { theme
          , needs:
              { topLeft: need
              , topRight: need
              , center: need
              , bottomLeft: need
              , bottomRight: need
              }
          }
      )

triggerBands :: HomeM Ɩ
triggerBands = do
  st <- get
  let
    currentIds :: Array ArticleId
    currentIds = case st.frontPage of
      Success fp ->
        let
          extractId :: QueryResult.Return (QueryResult.Fold (Maybe ArticleId) (Maybe UiSearchArticle)) -> Maybe ArticleId
          extractId (QueryResult.Given (QueryResult.Folded (Just id))) = Just id
          extractId (QueryResult.Given (QueryResult.Unfolded (Just a))) = case a.id of
            QueryResult.Given id -> Just id
            _ -> Nothing
          extractId _ = Nothing
        in
          Array.catMaybes
            [ extractId fp.topLeft
            , extractId fp.topRight
            , extractId fp.center
            , extractId fp.bottomLeft
            , extractId fp.bottomRight
            ]
      _ -> []

  case st.frontPage of
    Success _ -> do
      lastTriggeredRef <- case st.lastTriggeredFrontPageIds of
        Just r -> η r
        Nothing -> do
          r <- ʌ $ Ref.new Nothing
          modify_ (_lastTriggeredFrontPageIds .~ Just r)
          η r

      bandsForkIdRef <- case st.bandsForkId of
        Just r -> η r
        Nothing -> do
          r <- ʌ $ Ref.new Nothing
          modify_ (_bandsForkId .~ Just r)
          η r

      oldIdsOpt <- ʌ $ Ref.read lastTriggeredRef

      case oldIdsOpt of
        Just oldIds | oldIds == currentIds -> η ι
        _ -> do
          oldFidOpt <- ʌ $ Ref.read bandsForkIdRef
          case oldFidOpt of
            Just fid -> ø $ Halogen.kill fid
            Nothing -> η ι

          fid <- fork $ do
            ø $ fork loadNews
            ø $ fork loadMostRead
            ø $ fork loadNewsletterArticles
            ø $ fork loadQuote

          ʌ $ Ref.write (Just fid) bandsForkIdRef
          ʌ $ Ref.write (Just currentIds) lastTriggeredRef
    _ -> η ι

toUiFrontPageResult :: Result.Result -> UiFrontPageResult
toUiFrontPageResult res =
  { topLeft: res.topLeft <#> mapArticleFold
  , topRight: res.topRight <#> mapArticleFold
  , center: res.center <#> mapArticleFold
  , bottomLeft: res.bottomLeft <#> mapArticleFold
  , bottomRight: res.bottomRight <#> mapArticleFold
  }
  where
  mapArticleFold = case _ of
    QueryResult.Unfolded mArt -> QueryResult.Unfolded (mArt <#> toUiFrontPageArticle)
    QueryResult.Folded f -> QueryResult.Folded f

  toUiFrontPageArticle :: Article.Article_ -> UiSearchArticle
  toUiFrontPageArticle art =
    { id: art.id
    , legacyId: art.legacyId
    , title: art.title <#> HomeUtil.cleanNonEmpty
    , lead: art.lead <#> \l -> { lead: l.lead <#> map HomeUtil.cleanNonEmpty, isFallback: l.isFallback }
    , content: art.content <#> HomeUtil.cleanWpNonEmpty
    , notes: art.notes <#> map HomeUtil.cleanWpNonEmpty
    , sources: QueryResult.Given Nothing
    , theme: art.theme
    , author: art.author <#> map (\a -> { id: a.id, name: a.name <#> HomeUtil.cleanNonEmpty, biography: a.biography <#> map HomeUtil.cleanWpNonEmpty, portrait: a.portrait })
    , books: art.books <#> case _ of
        QueryResult.Unfolded bks -> QueryResult.Unfolded $ bks <#> \b ->
          { id: b.id
          , name: b.name <#> HomeUtil.cleanNonEmpty
          , year: b.year
          , cover: b.cover
          , authors: b.authors <#> map (\a -> { id: a.id, name: HomeUtil.cleanNonEmptyStripTags a.name })
          , editor: b.editor <#> map HomeUtil.cleanNonEmpty
          }
        QueryResult.Folded f -> QueryResult.Folded f
    , illustrations: art.illustrations <#> map (\ill -> { image: ill.image, caption: ill.caption <#> map HomeUtil.cleanNonEmpty, isFallback: ill.isFallback })
    , slug: art.slug
    }
