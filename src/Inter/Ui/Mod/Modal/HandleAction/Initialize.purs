module Inter.Ui.Mod.Modal.HandleAction.Initialize (initialize) where

import Proem

import Inter.Ui.Mod.Modal.Type (ModalM)
import Halogen (get)
import Util.Html.Dom.Dom (setBodyOverflowHidden)

initialize :: ∀ q i o. ModalM q i o Ɩ
initialize = do
  state <- get
  when state.input.open do
    setBodyOverflowHidden "modal"
