module Inter.Ui.UiM where

import Proem

import Config.PublicConfig (READER_PUBLIC_CONFIG, publicConfig, runPublicConfigReader)
import Data.Newtype (class Newtype, unwrap)
import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Aff.Class (class MonadAff)
import Effect.Class (class MonadEffect)
import Effect.Ref (Ref)
import Halogen.Store.Monad (class MonadStore)
import Halogen.Store.Select (selectEmitter)
import Inter.Ui.Capability.ApiCache.ApiCache (API_CACHE)
import Inter.Ui.Capability.ApiCache.ApiCache (CacheState, interpretApiCache) as ApiCache
import Inter.Ui.Capability.ArticleCache.ArticleCache (ARTICLE_CACHE, CacheState)
import Inter.Ui.Capability.ArticleCache.ArticleCache as ArticleCache
import Inter.Ui.Capability.Store.Store (STORE)
import Inter.Ui.Capability.Store.Store as Store
import Inter.Ui.Store.Store as GlobalStore
import Inter.Ui.Capability.Log.Log (LOG)
import Inter.Ui.Capability.Log.Log as Log
import Inter.Ui.Capability.Navigate.Navigate (NAVIGATE)
import Inter.Ui.Capability.Navigate.Navigate as Navigate
import Inter.Ui.Capability.Toast.Toast (TOAST)
import Inter.Ui.Capability.Toast.Toast as Toast
import Inter.Ui.Capability.Modal.Modal (MODAL)
import Inter.Ui.Capability.Modal.Modal as Modal
import Inter.Ui.Type.Toast (Toast) as T
import Inter.Ui.Type.ModalEvent (ModalEvent)
import Halogen.Subscription as HS
import Run (AFF, EFFECT, Run, runBaseAff')
import Type.Row (type (+))

type UI =
  STORE
    + LOG
    + NAVIGATE
    + TOAST
    + MODAL
    + READER_PUBLIC_CONFIG
    + ARTICLE_CACHE
    + API_CACHE
    + AFF
    + EFFECT
    + ()

newtype UiM a = UiM (Run UI a)

type Context =
  { articleCacheRef :: Ref CacheState
  , apiCacheRef :: Ref ApiCache.CacheState
  , toastListener :: HS.Listener T.Toast
  , modalListener :: HS.Listener ModalEvent
  , storeRef :: Ref GlobalStore.Store
  , storeListener :: HS.Listener GlobalStore.Store
  , storeEmitter :: HS.Emitter GlobalStore.Store
  , broadcastAuth :: String -> Effect Unit
  }

runUiM :: ∀ a. Context -> UiM a -> Aff a
runUiM { articleCacheRef, apiCacheRef, toastListener, modalListener, storeRef, storeListener, storeEmitter, broadcastAuth } =
  unwrap
    ▷ Store.interpretStore broadcastAuth storeRef storeListener storeEmitter
    ▷ Toast.interpretToast toastListener
    ▷ Modal.interpretModal modalListener
    ▷ Navigate.interpretNavigate
    ▷ Log.interpretLog
    ▷ ArticleCache.interpretArticleCache articleCacheRef
    ▷ ApiCache.interpretApiCache apiCacheRef
    ▷ runPublicConfigReader publicConfig
    ▷ runBaseAff'

derive instance Newtype (UiM a) _
derive newtype instance Functor UiM
derive newtype instance Apply UiM
derive newtype instance Applicative UiM
derive newtype instance Bind UiM
derive newtype instance Monad UiM
derive newtype instance MonadEffect UiM
derive newtype instance MonadAff UiM

instance MonadStore GlobalStore.Action GlobalStore.Store UiM where
  getStore = UiM Store.getStore
  updateStore action = UiM $ Store.updateStore action
  emitSelected selector = do
    emitter <- UiM Store.getStoreEmitter
    pure $ selectEmitter selector emitter
