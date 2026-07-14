module Inter.Ui.Mod.Link.HandleAction.HandleClick (handleClick) where

import Proem

import Inter.Ui.Capability.Navigate.Navigate (Route)
import Inter.Ui.Mod.Link.Type (LinkM, Output(..))
import Inter.Ui.Mod.Link.HandleAction.Navigate (navigate)
import Halogen (raise)
import Web.Event.Event (preventDefault)
import Web.UIEvent.MouseEvent (MouseEvent, altKey, button, ctrlKey, metaKey, shiftKey, toEvent)

handleClick :: Route -> MouseEvent -> LinkM Ɩ
handleClick route ev =
  when (isSimpleClick ev) do
    ʌ $ preventDefault $ toEvent ev
    raise $ Clicked route ev
    navigate route

isSimpleClick :: MouseEvent -> Boolean
isSimpleClick ev =
  button ev == 0
    && -- Left

      not (ctrlKey ev)
    && not (metaKey ev)
    && -- Cmd on macos

      not (shiftKey ev)
    &&
      not (altKey ev)
