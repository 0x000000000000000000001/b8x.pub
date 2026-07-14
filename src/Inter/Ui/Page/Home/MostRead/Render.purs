module Inter.Ui.Page.Home.MostRead.Render
  ( renderMostRead
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

renderMostRead :: State -> ComponentHTML Action Slots UiM
renderMostRead state = case state.mostReadArticles of
  Success articles
    | Array.length articles > 0 ->
      ArticlesBand.articlesBand { title: "Les plus lus" }
        (articles # Array.mapWithIndex \i art -> renderArticle false i (Just art))
  Loading ->
    ArticlesBand.articlesBand { title: "Les plus lus" }
      (Array.range 0 5 # map \i -> renderArticle true i Nothing)
  NotAsked ->
    ArticlesBand.articlesBand { title: "Les plus lus" }
      (Array.range 0 5 # map \i -> renderArticle true i Nothing)
  _ -> text ""

renderArticle :: Boolean -> Int -> Maybe UiSearchArticle -> ComponentHTML Action Slots UiM
renderArticle loading i mArt =
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
      ("most-read:" <> show i <> ":" <> toString uiArticle.slug)
