module Inter.Ui.Capability.Toast.Toast where

import Proem

import Halogen.Subscription as HS
import Inter.Ui.Type.Toast (Toast)
import Run (EFFECT, Run)
import Run as Run
import Type.Row (type (+))

data ToastAction a = ToastAction Toast a

derive instance Functor ToastAction

type TOAST fx = (toast :: ToastAction | fx)

toast' = π :: Π "toast"

toast_ :: ∀ fx. Toast -> Run (TOAST + fx) Ɩ
toast_ t = Run.lift toast' (ToastAction t unit)

interpretToast :: ∀ fx. HS.Listener Toast -> Run (TOAST + EFFECT + fx) ~> Run (EFFECT + fx)
interpretToast listener = Run.interpret (Run.on toast' handle Run.send)
  where
  handle :: ∀ a fx'. ToastAction a -> Run (EFFECT + fx') a
  handle (ToastAction t next) = do
    ʌ $ HS.notify listener t
    η next
