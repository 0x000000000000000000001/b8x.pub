module Inter.Ui.Page.Home.NewsletterArticles.Render
  ( renderNewsletterArticles
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

renderNewsletterArticles :: State -> ComponentHTML Action Slots UiM
renderNewsletterArticles state = case state.newsletterArticles of
  Success articles | Array.length articles > 0 ->
    ArticlesBand.articlesBand { title: "De la Booksletter" }
      (articles # Array.mapWithIndex \i art -> renderArticle false i (Just art))
  Loading ->
    ArticlesBand.articlesBand { title: "De la Booksletter" }
      (Array.range 0 5 # map \i -> renderArticle true i Nothing)
  NotAsked ->
    ArticlesBand.articlesBand { title: "De la Booksletter" }
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
      ("newsletter-articles:" <> show i <> ":" <> toString uiArticle.slug)
