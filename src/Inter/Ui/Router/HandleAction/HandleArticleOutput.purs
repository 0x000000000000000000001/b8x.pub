module Inter.Ui.Router.HandleAction.HandleArticleOutput
  ( handleArticleOutput
  ) where

import Proem

import Inter.Ui.Capability.Navigate.Navigate (Route(..))
import Inter.Ui.Page.Article.Type as PageArticle
import Inter.Ui.Router.Type (RouteM, Query(..))
import Inter.Ui.Router.HandleQuery (handleQuery)

handleArticleOutput :: PageArticle.Output -> RouteM Unit
handleArticleOutput PageArticle.ArticleNotFound = ø $ handleQuery (Navigate NotFound unit)
