module Inter.Ui.Page.Article.Related.Related
  (related
  ) where

import Proem hiding (div)

import Inter.Ui.Type.Model (UiSearchArticle)
import Data.Array as Array

import Halogen (ComponentHTML)
import Halogen.HTML (text, div_)
import Inter.Ui.Page.Article.Type (Action(..), Slots, State)
import Inter.Ui.UiM (UiM)
import Inter.Ui.Mod.ArticlesBand.ArticlesBand as ArticlesBand
import Inter.Ui.Mod.ArticleCard.Component (articleCard)
import Inter.Ui.Mod.ArticleCard.Util as ArticleCardUtil
import Util.Type.String.ToString (toString)
import Network.RemoteData (RemoteData(..))
import Data.Maybe (Maybe(..))
import Inter.Ui.Page.Article.Related.Style as Style

related :: State -> ComponentHTML Action Slots UiM
related state =
  let
    issueBand = case state.issueArticles of
      Success articles | Array.length articles >= 5 ->
        Style.wrapper_
          [ ArticlesBand.articlesBand { title: "Dans le même numéro" }
              (articles # Array.mapWithIndex \i art -> relatedArticle "issue" false i (Just art))
          ]
      Loading ->
        Style.wrapper_
          [ ArticlesBand.articlesBand { title: "Dans le même numéro" }
              (Array.range 0 5 # map \i -> relatedArticle "issue" true i Nothing)
          ]
      _ -> text ""

    relatedBand = case state.relatedArticles of
      Success articles | Array.length articles >= 5 ->
        Style.wrapper_
          [ ArticlesBand.articlesBand { title: "Cela pourrait vous intéresser" }
              (articles # Array.mapWithIndex \i art -> relatedArticle "related" false i (Just art))
          ]
      Loading ->
        Style.wrapper_
          [ ArticlesBand.articlesBand { title: "Cela pourrait vous intéresser" }
              (Array.range 0 5 # map \i -> relatedArticle "related" true i Nothing)
          ]
      _ -> text ""
  in
    div_ [ issueBand, relatedBand ]

relatedArticle :: String -> Boolean -> Int -> Maybe UiSearchArticle -> ComponentHTML Action Slots UiM
relatedArticle prefix loading i mArt =
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
      (\_ -> HandleArticleCardOutput (toString uiArticle.slug))
      (prefix <> ":" <> show i <> ":" <> toString uiArticle.slug)
