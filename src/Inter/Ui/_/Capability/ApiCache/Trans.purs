module Inter.Ui.Capability.ApiCache.Trans where

import Proem
import Yoga.JSON as Yoga.JSON

import Control.Monad.Trans.Class (class MonadTrans, lift)
import Data.Maybe (Maybe)
import Inter.Ui.Capability.ApiCache.ApiCache (ApiCacheEntry, getApiCache_, putApiCache_)
import Inter.Ui.UiM (UiM(..))
import Yoga.JSON (class WriteForeign)
import Effect.Aff.Class (class MonadAff)
import Util.Crypto.Hash (xxhash64)

getApiCache :: ∀ p t. WriteForeign p => MonadTrans t => MonadAff (t UiM) => String -> p -> t UiM (Maybe ApiCacheEntry)
getApiCache url payload = do
  key <- makeCacheKey url payload
  lift $ UiM $ getApiCache_ key

putApiCache :: ∀ p t. WriteForeign p => MonadTrans t => MonadAff (t UiM) => String -> p -> ApiCacheEntry -> t UiM Ɩ
putApiCache url payload entry = do
  key <- makeCacheKey url payload
  lift $ UiM $ putApiCache_ key entry

makeCacheKey :: ∀ p m. WriteForeign p => MonadAff m => String -> p -> m String
makeCacheKey url payload = do
  hash <- ʌ' $ xxhash64 $ Yoga.JSON.writeJSON payload
  η $ url <> "_" <> hash
