module Inter.Ui.Mod.Input.HandleAction.Index
  (handleAction
  ) where

import Proem

import Inter.Ui.Mod.Input.Type.Action (Action(..))
import Inter.Ui.Mod.Input.Type.InputM (InputM)
import Inter.Ui.Mod.Input.HandleAction.Initialize (initialize)
import Inter.Ui.Mod.Input.HandleAction.Receive (receive)
import Inter.Ui.Mod.Input.HandleAction.HandleFocus (handleFocus)
import Inter.Ui.Mod.Input.HandleAction.HandleBlur (handleBlur)
import Inter.Ui.Mod.Input.HandleAction.HandleClick (handleClick)
import Inter.Ui.Mod.Input.HandleAction.HandleLabelClick (handleLabelClick)
import Inter.Ui.Mod.Input.HandleAction.HandleLabelMouseDown (handleLabelMouseDown)
import Inter.Ui.Mod.Input.HandleAction.HandleUserInput (handleUserInput)

handleAction :: Action -> InputM Ɩ
handleAction = case _ of
  Initialize -> initialize
  Receive input -> receive input
  HandleUserInput newValue -> handleUserInput newValue
  HandleFocus -> handleFocus
  HandleBlur -> handleBlur
  HandleClick -> handleClick
  HandleLabelClick mouseEvent -> handleLabelClick mouseEvent
  HandleLabelMouseDown mouseEvent -> handleLabelMouseDown mouseEvent
