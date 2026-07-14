module Inter.Ui.Page.Home.News.Render
  (renderNews
  ) where

import Proem hiding (div)

import Data.Array as Array
import Halogen (ComponentHTML)
import Halogen.HTML (text)
import Inter.Ui.Type.Model (UiSearchArticle)
import Inter.Ui.Page.Home.Type (Action(..), Slots, State)
import Util.Type.String.ToString (toString)
import Inter.Ui.UiM (UiM)
import Inter.Ui.Mod.ArticleCard.Component (articleCard)
import Inter.Ui.Mod.ArticleCard.Util as ArticleCardUtil
import Network.RemoteData (RemoteData(..))
import Data.Maybe (Maybe(..))
import Inter.Ui.Mod.ArticlesBand.ArticlesBand as ArticlesBand

renderNews :: State -> ComponentHTML Action Slots UiM
renderNews state = case state.newsArticles of
  Success articles | Array.length articles >= 4 ->
    ArticlesBand.articlesBand { title: "Actualités" }
      (articles # Array.mapWithIndex \i art -> renderNewsArticle false i (Just art))
  Loading ->
    ArticlesBand.articlesBand { title: "Actualités" }
      (Array.range 0 5 # map \i -> renderNewsArticle true i Nothing)
  NotAsked ->
    ArticlesBand.articlesBand { title: "Actualités" }
      (Array.range 0 5 # map \i -> renderNewsArticle true i Nothing)
  _ -> text ""

renderNewsArticle :: Boolean -> Int -> Maybe UiSearchArticle -> ComponentHTML Action Slots UiM
renderNewsArticle loading i mArt =
  let
    uiArticle = case mArt of
      Just art -> ArticleCardUtil.inputUiArticle art
      Nothing -> ArticleCardUtil.emptyArticle
  in
    articleCard
      { loading
      , scale: 1.0
      , hiddenIllustration: false
      , maxChars: Just (ArticleCardUtil.computeMaxChars false uiArticle)
      , article: uiArticle
      , popOnHover: true
      , baseShadow: false
      }
      HandleArticleCardOutput
      ("news:" <> show i <> ":" <> toString uiArticle.slug)
