module Inter.Ui.Capability.Modal.Trans where

import Proem

import Control.Monad.Trans.Class (class MonadTrans, lift)
import Inter.Ui.Capability.Modal.Modal (modal_)
import Inter.Ui.Type.ModalEvent (ModalEvent(..))
import Inter.Ui.UiM (UiM(..))

openLoginModal :: ∀ t. MonadTrans t => t UiM Ɩ
openLoginModal = lift $ UiM $ modal_ OpenLoginModalEvent
