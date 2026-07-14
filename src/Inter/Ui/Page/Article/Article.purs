module Inter.Ui.Page.Article.Article
  ( article
  ) where

import Proem hiding (div)

import Core.Mod.Article.Slug.Slug (unsafeFromString)
import Halogen (ComponentHTML)
import Inter.Ui.Capability.Navigate.Navigate (Route(..))
import Inter.Ui.Page.Article.Component as ArticleComponent
import Inter.Ui.Router.Type (Action(..), Slots)
import Inter.Ui.UiM (UiM)

article :: Route -> ComponentHTML Action Slots UiM
article route = case route of
  Article slug _ -> ArticleComponent.article { slug } HandleArticleOutput
  _ -> ArticleComponent.article { slug: unsafeFromString "" } HandleArticleOutput
