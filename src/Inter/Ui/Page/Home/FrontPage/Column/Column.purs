module Inter.Ui.Page.Home.FrontPage.Column.Column where

import Proem hiding (div)

import Core.Message.Query.Result (Fold)
import Core.Mod.Article.Id.Id (ArticleId)
import Inter.Ui.Type.Model (UiSearchArticle)
import Data.Array (mapWithIndex)
import Data.Maybe (Maybe)
import Halogen (ComponentHTML)
import Inter.Ui.Page.Home.Type (Action, Slots)
import Inter.Ui.Page.Home.FrontPage.Column.Article.Article (article)
import Inter.Ui.Page.Home.FrontPage.Column.Style (column_)
import Inter.Ui.UiM (UiM)

column :: Int -> Boolean -> Array (Maybe (Fold (Maybe ArticleId) (Maybe UiSearchArticle))) -> ComponentHTML Action Slots UiM
column colIndex central articles =
  column_ central $ articles # mapWithIndex \i -> article central (i /= 1) colIndex i
