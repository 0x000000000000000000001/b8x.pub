module Inter.Ui.Router.Menu.HandleAction.HandleDocMouseMove (handleDocMouseMove) where

import Proem

import Data.Int (toNumber)
import Data.Maybe (Maybe(..))
import Effect.Ref as Ref
import Effect.Aff (Milliseconds(..), delay)
import Halogen (fork, get, getHTMLElementRef, modify_)
import Inter.Ui.Router.Menu.Core.Core (ref)
import Inter.Ui.Router.Menu.HandleAction.Close (close)
import Inter.Ui.Router.Menu.Type.MenuM (MenuM)
import Inter.Ui.Type.IntentOrigin (IntentOrigin(..))
import Inter.Ui.Type.ControlledState (ControlledState(..))
import Web.DOM.Element (getBoundingClientRect)
import Web.HTML.HTMLElement (toElement)
import Web.UIEvent.MouseEvent (MouseEvent, clientX)

handleDocMouseMove :: MouseEvent -> MenuM Ɩ
handleDocMouseMove mouseEvent = do
  { open: open', isDocMouseMoveThrottled, hasMouseEntered } <- get

  let
    open = case open' of
      Controlled o -> o
      Uncontrolled o -> o

  when (open && not isDocMouseMoveThrottled) do
    modify_ _ { isDocMouseMoveThrottled = true }
    _ <- fork do
      ʌ' $ delay $ Milliseconds 100.0
      modify_ _ { isDocMouseMoveThrottled = false }

    mHtmlElement <- getHTMLElementRef ref

    case mHtmlElement of
      Just htmlElement -> do
        rect <- ʌ $ getBoundingClientRect (toElement htmlElement)

        let
          x = toNumber $ clientX mouseEvent
          threshold = rect.width - 1.0

        case hasMouseEntered of
          Just ref' -> do
            hasMouseEnteredVal <- ʌ $ Ref.read ref'
            if x < threshold then do
              when (not hasMouseEnteredVal) do
                ʌ $ Ref.write true ref'
            else do
              when hasMouseEnteredVal do
                close Internal
          Nothing -> ηι

      Nothing -> ηι
