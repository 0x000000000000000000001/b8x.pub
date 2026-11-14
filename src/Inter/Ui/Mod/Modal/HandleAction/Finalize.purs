module Inter.Ui.Mod.Modal.HandleAction.Finalize (finalize) where

import Proem

import Inter.Ui.Mod.Modal.Type (ModalM)
import Util.Html.Dom.Dom (setBodyOverflowVisible)
import Halogen (get)

finalize :: ∀ q i o. ModalM q i o Ɩ
finalize = do
  state <- get
  when state.input.open do
    setBodyOverflowVisible "modal"
