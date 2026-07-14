module Inter.Ui.Mod.Toast.Component (component) where

import Proem hiding (div)

import Data.Array as Array
import Data.Tuple (Tuple(..))
import Effect.Aff (Milliseconds(..), delay)
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Inter.Ui.Mod.Toast.Style.Style as ToastStyle
import Inter.Ui.Mod.Toast.Type (Action(..), Input, Output, State, Query, ToastStatus(..))
import Inter.Ui.Type.Toast (Toast, ToastType(..))
import Inter.Ui.UiM (UiM)
import Data.Maybe (Maybe(..))

component :: H.Component Query Input Output UiM
component = H.mkComponent
  { initialState: \input -> { toasts: [], emitter: input.toastEmitter, nextId: 0 }
  , render
  , eval: H.mkEval $ H.defaultEval
      { handleAction = handleAction
      , initialize = Just Initialize
      }
  }

render :: State -> H.ComponentHTML Action () UiM
render state =
  ToastStyle.toastContainerKeyed
    (map (\x -> Tuple (show x.tId) (renderToast x)) state.toasts)

renderToast :: { tId :: Int, version :: Int, toast :: Toast, status :: ToastStatus } -> H.ComponentHTML Action () UiM
renderToast { tId, version, toast: t, status } =
  let
    bgClass = case t.tType of
      Success -> "#22c55e"
      Error -> "#ef4444"
      Info -> "#3b82f6"
      Warning -> "#f59e0b"
  in
    ToastStyle.toastItem bgClass status [ HE.onClick \_ -> StartRemoveToastInternal tId version ]
      [ HH.text t.message ]

handleAction :: Action -> H.HalogenM State Action () Output UiM Unit
handleAction = case _ of
  Initialize -> do
    state <- H.get
    _ <- H.subscribe (state.emitter <#> ReceiveToast)
    pure unit

  ReceiveToast t -> do
    st <- H.get
    let mExisting = Array.head $ Array.filter (\x -> x.toast.id == t.id && x.status /= Exiting) st.toasts
    case mExisting of
      Just existing -> do
        let newVersion = existing.version + 1
        H.modify_ \s -> s { toasts = map (\x -> if x.tId == existing.tId then x { toast = t, version = newVersion } else x) s.toasts }
        _ <- H.fork do
          H.liftAff $ delay (Milliseconds 4000.0)
          handleAction (StartRemoveToastInternal existing.tId newVersion)
        pure unit
      Nothing -> do
        let newToast = { tId: st.nextId, version: 0, toast: t, status: Entering }
        H.modify_ \s -> s { toasts = Array.cons newToast s.toasts, nextId = s.nextId + 1 }
        _ <- H.fork do
          H.liftAff $ delay (Milliseconds 50.0)
          handleAction (ActivateToastInternal newToast.tId)
        _ <- H.fork do
          H.liftAff $ delay (Milliseconds 4000.0)
          handleAction (StartRemoveToastInternal newToast.tId 0)
        pure unit

  ActivateToastInternal tid -> do
    H.modify_ \st -> st { toasts = map (\x -> if x.tId == tid then x { status = Active } else x) st.toasts }
    pure unit

  StartRemoveToastInternal tid version -> do
    st <- H.get
    case Array.findIndex (\x -> x.tId == tid && x.version == version) st.toasts of
      Just _ -> do
        H.modify_ \s -> s { toasts = map (\x -> if x.tId == tid then x { status = Exiting } else x) s.toasts }
        _ <- H.fork do
          H.liftAff $ delay (Milliseconds 300.0)
          handleAction (RemoveToastInternal tid)
        pure unit
      Nothing -> pure unit

  RemoveToastInternal tid -> do
    H.modify_ \st -> st { toasts = Array.filter (\x -> x.tId /= tid) st.toasts }
