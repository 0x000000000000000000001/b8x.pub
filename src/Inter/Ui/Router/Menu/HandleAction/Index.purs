module Inter.Ui.Router.Menu.HandleAction.Index (handleAction) where

import Proem

import Data.Maybe (Maybe(..))

import Inter.Ui.Capability.Modal.Trans (openLoginModal)
import Inter.Ui.Router.Menu.HandleAction.Close (close)
import Inter.Ui.Router.Menu.HandleAction.CloseActivePanel (closeActivePanel)
import Inter.Ui.Router.Menu.HandleAction.CloseMagazine (closeMagazine)
import Inter.Ui.Router.Menu.HandleAction.CloseNewsletter (closeNewsletter)
import Inter.Ui.Router.Menu.HandleAction.CloseSearch (closeSearch)
import Inter.Ui.Router.Menu.HandleAction.DoNothing (doNothing)
import Inter.Ui.Router.Menu.HandleAction.FetchResults (fetchResults)
import Inter.Ui.Router.Menu.HandleAction.GoToMagazineCovers (goToMagazineCovers)
import Inter.Ui.Router.Menu.HandleAction.GoToMagazineArticles (goToMagazineArticles)
import Inter.Ui.Router.Menu.HandleAction.GoToNewsletterArticles (goToNewsletterArticles)
import Inter.Ui.Router.Menu.HandleAction.GoToNewsletterMonths (goToNewsletterMonths)
import Inter.Ui.Router.Menu.HandleAction.HandleDocClick (handleDocClick)
import Inter.Ui.Router.Menu.HandleAction.HandleDocMouseMove (handleDocMouseMove)
import Inter.Ui.Router.Menu.HandleAction.HandleLinkOutput.Index (handleLinkOutput)
import Inter.Ui.Router.Menu.HandleAction.HandleSearchInputOutput.Index (handleSearchInputOutput)
import Inter.Ui.Router.Menu.HandleAction.Initialize (initialize)
import Inter.Ui.Router.Menu.HandleAction.Open (open)
import Inter.Ui.Router.Menu.HandleAction.OpenMagazine (openMagazine)
import Inter.Ui.Router.Menu.HandleAction.OpenNewsletter (openNewsletter)
import Inter.Ui.Router.Menu.HandleAction.OpenSearch (openSearch)
import Inter.Ui.Router.Menu.HandleAction.Receive (receive)
import Inter.Ui.Router.Menu.HandleAction.RemoveAuthorFilter (handleActionRemoveAuthorFilter)
import Inter.Ui.Router.Menu.HandleAction.Logout (logout)
import Inter.Ui.Router.Menu.Type.Action (Action(..))
import Inter.Ui.Router.Menu.Type.MenuM (MenuM)
import Inter.Ui.Type.IntentOrigin (IntentOrigin(..))

handleAction :: Action -> MenuM Ɩ
handleAction = case _ of
  Open -> open Internal
  Close -> close Internal
  HandleSearchInputOutput output -> handleSearchInputOutput output
  HandleLinkOutput output -> handleLinkOutput output
  RemoveAuthorFilter -> handleActionRemoveAuthorFilter
  FetchResults -> fetchResults
  CloseSearch -> closeSearch Internal
  OpenSearch -> openSearch Internal Nothing
  OpenNewsletter -> openNewsletter Internal
  CloseNewsletter -> closeNewsletter Internal
  GoToNewsletterMonths year -> goToNewsletterMonths year
  GoToNewsletterArticles year month mId fromShortcut -> goToNewsletterArticles year month mId fromShortcut
  OpenMagazine -> openMagazine Internal
  CloseMagazine -> closeMagazine Internal
  GoToMagazineCovers year -> goToMagazineCovers year
  GoToMagazineArticles year slug -> goToMagazineArticles Internal (Just year) slug
  DoNothing -> doNothing
  Receive input -> receive input
  Initialize -> initialize
  HandleDocMouseMove mouseEvent -> handleDocMouseMove mouseEvent
  HandleDocClick mouseEvent -> handleDocClick mouseEvent
  CloseActivePanel -> closeActivePanel Internal

  Logout -> logout
  OpenLoginModal -> openLoginModal
