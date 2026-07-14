module Inter.Ui.Router.HandleAction.HandleDocScroll (handleDocScroll) where

import Proem

import Data.Foldable (for_)
import Effect.Aff (Milliseconds(..), delay)
import Effect.Ref (read, write)
import Halogen (fork, get, kill)
import Inter.Ui.Router.Type (RouteM)
import Data.Maybe (Maybe(..))
import Inter.Ui.Router.HandleAction.HandleDocScrollEnd (handleDocScrollEnd)

handleDocScroll :: RouteM Unit
handleDocScroll = do
  state <- get

  for_ state.scrollFork \ref -> do
    maybeForkId <- ʌ $ read ref
    for_ maybeForkId kill

  forkId <- fork do
    ʌ' $ delay $ Milliseconds 300.0
    handleDocScrollEnd

  for_ state.scrollFork \ref ->
    ʌ $ write (Just forkId) ref
