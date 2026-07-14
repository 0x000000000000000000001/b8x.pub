module Inter.Ui.Router.Menu.HandleAction.Initialize (initialize) where

import Proem

import Data.Maybe (Maybe(..))
import Halogen (modify_, subscribe')
import Halogen.Query.Event (eventListener)
import Inter.Ui.Router.Menu.Type.Action (Action(..))
import Inter.Ui.Router.Menu.Type.MenuM (MenuM)
import Web.DOM.Document (toEventTarget)
import Web.HTML (window)
import Web.HTML.HTMLDocument (toDocument)
import Web.HTML.Window (document)
import Web.UIEvent.MouseEvent (fromEvent)
import Web.UIEvent.MouseEvent.EventTypes (mousedown, mousemove)
import Effect.Ref as Ref
import Inter.Ui.Router.Menu.Type.State.State (_hasMouseEntered)
import Data.Lens ((.~))


initialize :: MenuM Ɩ
initialize = do
  doc <- ʌ $ document =<< window

  ref <- ʌ $ Ref.new false
  modify_ (_hasMouseEntered .~ Just ref)

  subscribe' $ κ $ eventListener
    mousemove
    (doc # toDocument # toEventTarget)
    (fromEvent >=> (HandleDocMouseMove ▷ Just))

  subscribe' $ κ $ eventListener
    mousedown
    (doc # toDocument # toEventTarget)
    (fromEvent >=> (HandleDocClick ▷ Just))


