module Inter.Ui.Router.HandleAction.Index
  (handleAction
  ) where

import Proem

import Inter.Ui.Router.Type (Action, RouteM)
import Inter.Ui.Router.Type as Router
import Inter.Ui.Type.ModalEvent (ModalEvent(..))
import Halogen (tell)
import Inter.Ui.Mod.LoginModal.Type as LoginModal
import Inter.Ui.Type.Slot (noSlotAddressIndex)
import Type.Proxy (Proxy(..))
import Inter.Ui.Router.HandleAction.Initialize (initialize)
import Inter.Ui.Router.HandleAction.HandleDocScroll (handleDocScroll)
import Inter.Ui.Router.HandleAction.HandleDocScrollEnd (handleDocScrollEnd)
import Inter.Ui.Router.HandleAction.HandleMenuOutput.Index (handleMenuOutput)
import Inter.Ui.Router.HandleAction.HandleArticleOutput (handleArticleOutput)

handleAction :: Action -> RouteM Unit
handleAction = case _ of
  Router.Initialize -> initialize
  Router.HandleModalEvent OpenLoginModalEvent -> tell (Proxy @"loginModal") noSlotAddressIndex (LoginModal.Open)
  Router.HandleDocScroll -> handleDocScroll
  Router.HandleDocScrollEnd -> handleDocScrollEnd
  Router.HandleMenuOutput output -> handleMenuOutput output
  Router.HandleLinkOutput _ -> ηι
  Router.HandleArticleOutput output -> handleArticleOutput output
