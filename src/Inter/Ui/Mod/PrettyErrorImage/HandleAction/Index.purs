module Inter.Ui.Mod.PrettyErrorImage.HandleAction.Index
  (handleAction
  ) where

import Proem

import Inter.Ui.Mod.PrettyErrorImage.Type (Action(..), PrettyErrorImageM)
import Inter.Ui.Mod.PrettyErrorImage.HandleAction.HandleError (handleError)
import Inter.Ui.Mod.PrettyErrorImage.HandleAction.Receive (receive)

handleAction :: Action -> PrettyErrorImageM Ɩ
handleAction = case _ of
  HandleError -> handleError
  Receive i -> receive i