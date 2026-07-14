module Inter.Ui.Page.Home.FrontPage.Column.Article.Article where

import Proem hiding (div)
import Core.Message.Query.Result (Fold(..), Return(..))
import Data.Maybe (Maybe(..))
import Halogen (ComponentHTML)
import Inter.Ui.Page.Home.Type (Action(..), Slots)
import Inter.Ui.UiM (UiM)
import Inter.Ui.Mod.ArticleCard.Component (articleCard)
import Util.Type.String.ToString (toString)
import Core.Mod.Article.Slug.Slug (unsafeFromString) as Slug
import Util.Html.Clean.Render.Render (SanitizedHtmlString(..))

import Core.Mod.Article.Id.Id (ArticleId)
import Inter.Ui.Type.Model (UiSearchArticle)
import Inter.Ui.Mod.ArticleCard.Util as ArticleCardUtil

article :: Boolean -> Boolean -> Int -> Int -> Maybe (Fold (Maybe ArticleId) (Maybe UiSearchArticle)) -> ComponentHTML Action Slots UiM
article central visibleIllustration colIndex index = case _ of
  Just
    ( Unfolded
      ( Just art
    )
  ) ->
    let
      uiArticle = ArticleCardUtil.inputUiArticle art
    in
      articleCard
        { loading: false
        , scale: (if central then 1.4 else 1.0)
        , hiddenIllustration: not visibleIllustration
        , maxChars: Nothing
        , article: uiArticle
        , popOnHover: false
        , baseShadow: true
        }
        HandleArticleCardOutput
        ( "frontPage:" <> show colIndex <> ":" <> show index <> ":"
            <> ( case art.slug of
                  Given s -> toString s
                  _ -> ""
              )
        )
  _ -> skeleton central visibleIllustration colIndex index

skeleton :: Boolean -> Boolean -> Int -> Int -> ComponentHTML Action Slots UiM
skeleton central visibleIllustration colIndex index =
  articleCard
    { loading: true
    , scale: (if central then 1.4 else 1.0)
    , hiddenIllustration: not visibleIllustration
    , maxChars: Nothing
    , article:
        { slug: Slug.unsafeFromString ""
        , title: SanitizedHtmlString ""
        , lead: { lead: Nothing, isFallback: false }
        , bookAuthors: []
        , author: Nothing
        , illustration: Nothing
        }
    , popOnHover: false
    , baseShadow: true
    }
    HandleArticleCardOutput
    ("skeleton:" <> show colIndex <> ":" <> show index)
