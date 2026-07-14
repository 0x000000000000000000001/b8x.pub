module Inter.Ui.Router.HandleAction.Initialize (initialize) where

import Proem

import Effect.Ref (new)
import Halogen (modify_, subscribe', subscribe, get)
import Halogen.Query.Event (eventListener)
import Inter.Ui.Router.Type (Action(..), RouteM)
import Inter.Ui.Router.Type as Router
import Util.Html.Dom.Dom (scroll)
import Web.DOM.Document (toEventTarget)
import Web.HTML (window)
import Web.HTML.HTMLDocument (toDocument)
import Web.HTML.Window (document)
import Data.Maybe (Maybe(..))

initialize :: RouteM Unit
initialize = do
  doc <- ʌ $ document =<< window

  ref <- ʌ $ new Nothing
  state <- get
  _ <- subscribe (state.modalEmitter <#> HandleModalEvent)
  modify_ _ { scrollFork = Just ref }

  subscribe' $ κ $ eventListener
    scroll
    (doc # toDocument # toEventTarget)
    (Router.HandleDocScroll # Just # κ)
