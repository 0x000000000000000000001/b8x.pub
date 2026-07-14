module Inter.Ui.Capability.Toast.Trans where

import Proem

import Control.Monad.Trans.Class (class MonadTrans, lift)
import Inter.Ui.Capability.Toast.Toast (toast_)
import Inter.Ui.Type.Toast (Toast)
import Inter.Ui.UiM (UiM(..))

toast :: ∀ t. MonadTrans t => Toast -> t UiM Ɩ
toast t = lift $ UiM $ toast_ t
