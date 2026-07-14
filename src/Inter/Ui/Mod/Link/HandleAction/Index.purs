module Inter.Ui.Mod.Link.HandleAction.Index
  (handleAction
  ) where

import Proem

import Inter.Ui.Mod.Link.Type (Action(..), LinkM)
import Inter.Ui.Mod.Link.HandleAction.Receive (receive)
import Inter.Ui.Mod.Link.HandleAction.Navigate (navigate)
import Inter.Ui.Mod.Link.HandleAction.HandleClick (handleClick)

handleAction :: Action -> LinkM Ɩ
handleAction = case _ of
  Receive input -> receive input
  Navigate route -> navigate route
  HandleClick route ev -> handleClick route ev