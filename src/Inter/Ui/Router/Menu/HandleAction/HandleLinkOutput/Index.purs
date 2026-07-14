module Inter.Ui.Router.Menu.HandleAction.HandleLinkOutput.Index (handleLinkOutput) where

import Proem

import Inter.Ui.Mod.Link.Type as Link
import Inter.Ui.Router.Menu.Type.MenuM (MenuM)
import Inter.Ui.Router.Menu.HandleAction.HandleLinkOutput.Clicked (handleLinkOutputClicked)

handleLinkOutput :: Link.Output -> MenuM Ɩ
handleLinkOutput = case _ of
  Link.Clicked route mouseEvent -> handleLinkOutputClicked route mouseEvent
