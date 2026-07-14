module Inter.Ui.Mod.Modal.HandleAction.HandleClick (handleClick) where

import Proem

import Inter.Ui.Mod.Modal.Style.Style as Modal
import Inter.Ui.Mod.Modal.Type (ModalM, Output(..))
import Data.String (Pattern(..), contains)
import Halogen (get)
import Halogen.Query.HalogenM (raise)
import Web.DOM.Element (className)
import Web.Event.Event (target)
import Web.HTML.HTMLElement (fromEventTarget, toElement)
import Web.UIEvent.MouseEvent (MouseEvent, toEvent)

handleClick :: ∀ q i o. MouseEvent -> ModalM q i o Ɩ
handleClick mouseEvent = do
  state <- get

  when state.input.closable do
    let
      event = toEvent mouseEvent
      eventTarget = target event
      htmlElement = eventTarget >>= fromEventTarget
      element = htmlElement >>= (η ◁ toElement)

    classNameStr <- element ?? (ʌ ◁ className) ⇔ η ""

    let shouldClose = contains (Pattern $ Modal.class' state.id) classNameStr

    when shouldClose (raise Closed)
