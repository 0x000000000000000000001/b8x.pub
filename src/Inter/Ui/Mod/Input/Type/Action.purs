module Inter.Ui.Mod.Input.Type.Action where

import Inter.Ui.Mod.Input.Type.Input (Input)
import Web.UIEvent.MouseEvent (MouseEvent)

data Action
  = Initialize
  | Receive Input
  | HandleUserInput String
  | HandleFocus
  | HandleBlur
  | HandleClick
  | HandleLabelClick MouseEvent
  | HandleLabelMouseDown MouseEvent
