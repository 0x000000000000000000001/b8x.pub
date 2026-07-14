module Inter.Ui.Router.Menu.HandleAction.HandleDocClick (handleDocClick) where

import Proem

import Data.Int (toNumber)
import Data.Maybe (Maybe(..))
import Halogen (get, getHTMLElementRef)
import Inter.Ui.Router.Menu.Core.Core (ref)
import Inter.Ui.Router.Menu.HandleAction.Close (close)
import Inter.Ui.Router.Menu.Type.MenuM (MenuM)
import Inter.Ui.Type.IntentOrigin (IntentOrigin(..))
import Inter.Ui.Type.ControlledState (ControlledState(..))
import Web.DOM.Element (getBoundingClientRect)
import Web.HTML.HTMLElement (toElement)
import Web.UIEvent.MouseEvent (MouseEvent, clientX)

handleDocClick :: MouseEvent -> MenuM Ɩ
handleDocClick mouseEvent = do
  { open: open' } <- get

  let
    open = case open' of
      Controlled o -> o
      Uncontrolled o -> o

  when open do
    mHtmlElement <- getHTMLElementRef ref

    case mHtmlElement of
      Just htmlElement -> do
        rect <- ʌ $ getBoundingClientRect (toElement htmlElement)

        let
          x = toNumber $ clientX mouseEvent
          threshold = rect.width - 1.0

        when (x > threshold) do
          close Internal

      Nothing -> ηι
