module Inter.Ui.Mod.Modal.HandleAction.Index
  (handleAction
  ) where

import Proem

import Inter.Ui.Mod.Modal.Type (Action(..), ModalM)
import Inter.Ui.Mod.Modal.HandleAction.Initialize (initialize)
import Inter.Ui.Mod.Modal.HandleAction.Receive (receive)
import Inter.Ui.Mod.Modal.HandleAction.HandleCloseClick (handleCloseClick)
import Inter.Ui.Mod.Modal.HandleAction.HandleClick (handleClick)
import Inter.Ui.Mod.Modal.HandleAction.RaiseInnerOutput (raiseInnerOutput)

handleAction :: ∀ q i o. Action i o -> (ModalM q i o) Ɩ
handleAction = case _ of
  Initialize -> initialize
  Receive input -> receive input
  HandleCloseClick -> handleCloseClick
  HandleClick mouseEvent -> handleClick mouseEvent
  RaiseInnerOutput output -> raiseInnerOutput output
