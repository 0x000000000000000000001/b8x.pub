module Inter.Ui.Capability.Store.Store where

import Proem
import Yoga.JSON as Yoga.JSON

import Effect.Ref (Ref)
import Effect.Ref as Ref
import Effect (Effect)
import Halogen.Subscription as HS
import Halogen.Subscription (Emitter)
import Inter.Ui.Store.Store as GlobalStore
import Run (EFFECT, Run)
import Run as Run
import Type.Row (type (+))

data StoreAction a
  = GetStore (GlobalStore.Store -> a)
  | UpdateStore GlobalStore.Action a
  | GetEmitter (Emitter GlobalStore.Store -> a)

derive instance Functor StoreAction

type STORE fx = (store :: StoreAction | fx)

store' = π :: Π "store"

getStore :: ∀ fx. Run (STORE + fx) GlobalStore.Store
getStore = Run.lift store' (GetStore identity)

updateStore :: ∀ fx. GlobalStore.Action -> Run (STORE + fx) Ɩ
updateStore a = Run.lift store' (UpdateStore a unit)

getStoreEmitter :: ∀ fx. Run (STORE + fx) (Emitter GlobalStore.Store)
getStoreEmitter = Run.lift store' (GetEmitter identity)

interpretStore :: ∀ fx. (String -> Effect Unit) -> Ref GlobalStore.Store -> HS.Listener GlobalStore.Store -> Emitter GlobalStore.Store -> Run (STORE + EFFECT + fx) ~> Run (EFFECT + fx)
interpretStore broadcast ref listener emitter = Run.interpret (Run.on store' handle Run.send)
  where
  handle :: ∀ a fx'. StoreAction a -> Run (EFFECT + fx') a
  handle = case _ of
    GetStore next -> do
      store <- ʌ $ Ref.read ref
      η (next store)
    UpdateStore action next -> do
      store <- ʌ $ Ref.read ref
      let newStore = GlobalStore.reduce store action
      ʌ $ Ref.write newStore ref
      ʌ $ HS.notify listener newStore
      ʌ $ broadcast (Yoga.JSON.writeJSON (newStore.me))
      η next
    GetEmitter next -> η (next emitter)
