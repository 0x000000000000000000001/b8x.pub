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

import Inter.Ui.Type.Device (Device)

article :: Device -> Route -> ComponentHTML Action Slots UiM
article device route = case route of
  Article slug _ -> ArticleComponent.article { slug, context: device } HandleArticleOutput
  _ -> ArticleComponent.article { slug: unsafeFromString "", context: device } HandleArticleOutput
