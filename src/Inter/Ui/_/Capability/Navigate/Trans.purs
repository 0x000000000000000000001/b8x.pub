module Inter.Ui.Capability.Navigate.Trans where

import Proem

import Control.Monad.Trans.Class (class MonadTrans, lift)
import Data.Maybe (Maybe)
import Inter.Ui.Capability.Navigate.Navigate (Route, navigate_, updateMeta_)
import Inter.Api.Social.Meta.Type (Meta)
import Inter.Ui.UiM (UiM(..))

navigate :: ∀ t. MonadTrans t => Route -> t UiM Ɩ
navigate route = lift $ UiM $ navigate_ route

updateMeta :: ∀ t. MonadTrans t => Maybe Meta -> t UiM Ɩ
updateMeta meta = lift $ UiM $ updateMeta_ meta
