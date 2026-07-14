module Inter.Ui.Mod.Input.HandleAction.HandleLabelMouseDown (handleLabelMouseDown) where

import Proem

import Inter.Ui.Mod.Input.Type.InputM (InputM)
import Web.Event.Event (preventDefault, stopPropagation)
import Web.UIEvent.MouseEvent (MouseEvent, toEvent)

handleLabelMouseDown :: MouseEvent -> InputM Ɩ
handleLabelMouseDown mouseEvent = do
  let event = toEvent mouseEvent

  ʌ $ preventDefault event
  ʌ $ stopPropagation event
