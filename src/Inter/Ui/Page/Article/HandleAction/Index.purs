module Inter.Ui.Page.Article.HandleAction.Index
  ( handleAction
  ) where

import Proem

import Inter.Ui.Page.Article.Type (Action(..), ArticleM)
import Inter.Ui.Page.Article.HandleAction.Load (load)
import Inter.Ui.Page.Article.HandleAction.Receive (receive)
import Inter.Ui.Page.Article.HandleAction.Initialize (initialize)

import Halogen (gets)
import Halogen as H
import Web.Event.Event (preventDefault, stopPropagation)
import Web.UIEvent.MouseEvent as MouseEvent
import Inter.Ui.Capability.Navigate.Trans (navigate)
import Inter.Ui.Capability.Navigate.Navigate (Route(..))
import Data.Maybe (Maybe(..))

handleAction :: Action -> ArticleM Ɩ
handleAction = case _ of
  Initialize -> initialize
  Load -> load
  Receive input -> receive input
  HandleArticleCardOutput _ -> ηι
  ClickAuthor e authorInfo -> do
    ʌ $ H.liftEffect $ stopPropagation (MouseEvent.toEvent e)
    ʌ $ H.liftEffect $ preventDefault (MouseEvent.toEvent e)
    { slug } <- gets _.input
    navigate (Article slug { consumeMagicLoginToken: Nothing, menu: { magazineIssueOpen: Nothing, search: { openWith: Nothing, withAuthorFilter: Just authorInfo } } })
