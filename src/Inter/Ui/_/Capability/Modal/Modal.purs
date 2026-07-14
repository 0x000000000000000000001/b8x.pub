module Inter.Ui.Capability.Modal.Modal where

import Proem

import Halogen.Subscription as HS
import Inter.Ui.Type.ModalEvent (ModalEvent)
import Run (EFFECT, Run)
import Run as Run
import Type.Row (type (+))

data ModalAction a = ModalAction ModalEvent a

derive instance Functor ModalAction

type MODAL fx = (modal :: ModalAction | fx)

modal' = π :: Π "modal"

modal_ :: ∀ fx. ModalEvent -> Run (MODAL + fx) Ɩ
modal_ t = Run.lift modal' (ModalAction t unit)

interpretModal :: ∀ fx. HS.Listener ModalEvent -> Run (MODAL + EFFECT + fx) ~> Run (EFFECT + fx)
interpretModal listener = Run.interpret (Run.on modal' handle Run.send)
  where
  handle :: ∀ a fx'. ModalAction a -> Run (EFFECT + fx') a
  handle (ModalAction t next) = do
    ʌ $ HS.notify listener t
    η next
