module Inter.Ui.Mod.Modal.HandleAction.Receive (receive) where

import Proem

import Inter.Ui.Mod.Modal.Type (Input, ModalM)
import Halogen (get, modify_)
import Util.Html.Dom.Dom (setBodyOverflowHidden, setBodyOverflowVisible)

receive :: ∀ q i o. Input i -> ModalM q i o Ɩ
receive input = do
  oldState <- get
  modify_ _ { input = input }
  when (input.open /= oldState.input.open) do
    if input.open then
      setBodyOverflowHidden "modal"
    else
      setBodyOverflowVisible "modal"
