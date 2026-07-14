module Inter.Ui.Capability.Store.Trans where

import Proem

import Control.Monad.Trans.Class (class MonadTrans, lift)
import Halogen.Subscription (Emitter)
import Inter.Ui.Capability.Store.Store as StoreCap
import Inter.Ui.Store.Store as GlobalStore
import Inter.Ui.UiM (UiM(..))

getStore :: ∀ t. MonadTrans t => t UiM GlobalStore.Store
getStore = lift $ UiM $ StoreCap.getStore

updateStore :: ∀ t. MonadTrans t => GlobalStore.Action -> t UiM Ɩ
updateStore a = lift $ UiM $ StoreCap.updateStore a

getStoreEmitter :: ∀ t. MonadTrans t => t UiM (Emitter GlobalStore.Store)
getStoreEmitter = lift $ UiM $ StoreCap.getStoreEmitter
