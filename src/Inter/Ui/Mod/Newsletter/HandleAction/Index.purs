module Inter.Ui.Mod.Newsletter.HandleAction.Index (handleAction) where

import Inter.Ui.Mod.Newsletter.HandleAction.HandleInput (handleInput)
import Inter.Ui.Mod.Newsletter.HandleAction.Submit (submit)
import Inter.Ui.Mod.Newsletter.Type (Action(..), NewsletterM)
import Data.Unit (Unit)

handleAction :: Action -> NewsletterM Unit
handleAction = case _ of
  HandleInput out -> handleInput out
  Submit event -> submit event
