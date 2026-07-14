module Inter.Ui.Mod.Modal.HandleAction.RaiseInnerOutput (raiseInnerOutput) where

import Proem

import Inter.Ui.Mod.Modal.Type (ModalM, Output(..))
import Halogen.Query.HalogenM (raise)

raiseInnerOutput :: ∀ q i o. o -> ModalM q i o Ɩ
raiseInnerOutput output = raise (InnerOutputRaised output)
