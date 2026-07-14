module Inter.Ui.Mod.Input.HandleAction.HandleLabelClick (handleLabelClick) where

import Proem

import Inter.Ui.Mod.Input.Type.InputM (InputM)
import Inter.Ui.Mod.Input.HandleAction.HandleClick (handleClick)
import Web.Event.Event (preventDefault, stopPropagation)
import Web.UIEvent.MouseEvent (MouseEvent, toEvent)

handleLabelClick :: MouseEvent -> InputM Ɩ
handleLabelClick mouseEvent = do
  let event = toEvent mouseEvent

  ʌ $ preventDefault event
  ʌ $ stopPropagation event

  handleClick
