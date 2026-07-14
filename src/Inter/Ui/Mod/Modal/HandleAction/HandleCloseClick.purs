module Inter.Ui.Mod.Modal.HandleAction.HandleCloseClick (handleCloseClick) where

import Proem

import Inter.Ui.Mod.Modal.Type (ModalM, Output(..))
import Halogen.Query.HalogenM (raise)

handleCloseClick :: ∀ q i o. ModalM q i o Ɩ
handleCloseClick = raise Closed
