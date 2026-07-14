module Inter.Ui.Capability.Log.Trans where

import Proem

import Control.Monad.Trans.Class (class MonadTrans, lift)
import Inter.Ui.Capability.Log.Log as Log
import Inter.Ui.UiM (UiM(..))
import Util.Log (Level)

log :: ∀ t. MonadTrans t => Level -> String -> t UiM Ɩ
log lvl msg = lift $ UiM $ Log.log_ lvl msg

logShow :: ∀ a t. MonadTrans t => Show a => Level -> a -> t UiM Ɩ
logShow lvl a = lift $ UiM $ Log.logShow_ lvl a

info :: ∀ t. MonadTrans t => String -> t UiM Ɩ
info msg = lift $ UiM $ Log.info_ msg

infoShow :: ∀ a t. MonadTrans t => Show a => a -> t UiM Ɩ
infoShow a = lift $ UiM $ Log.infoShow_ a

debug :: ∀ t. MonadTrans t => String -> t UiM Ɩ
debug msg = lift $ UiM $ Log.debug_ msg

debugShow :: ∀ a t. MonadTrans t => Show a => a -> t UiM Ɩ
debugShow a = lift $ UiM $ Log.debugShow_ a

warn :: ∀ t. MonadTrans t => String -> t UiM Ɩ
warn msg = lift $ UiM $ Log.warn_ msg

warnShow :: ∀ a t. MonadTrans t => Show a => a -> t UiM Ɩ
warnShow a = lift $ UiM $ Log.warnShow_ a

error :: ∀ t. MonadTrans t => String -> t UiM Ɩ
error msg = lift $ UiM $ Log.error_ msg

errorShow :: ∀ a t. MonadTrans t => Show a => a -> t UiM Ɩ
errorShow a = lift $ UiM $ Log.errorShow_ a
