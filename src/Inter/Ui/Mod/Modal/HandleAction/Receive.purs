module Inter.Ui.Mod.Modal.HandleAction.Receive (receive) where

import Proem

import Inter.Ui.Mod.Modal.Type (Input, ModalM)
import Halogen (modify_)

receive :: ∀ q i o. Input i -> ModalM q i o Ɩ
receive input = modify_ _ { input = input }
