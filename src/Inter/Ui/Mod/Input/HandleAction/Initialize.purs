module Inter.Ui.Mod.Input.HandleAction.Initialize (initialize) where

import Proem

import Data.Maybe (Maybe(..))
import Effect.Ref (new)
import Halogen (modify_, getHTMLElementRef, get)
import Inter.Ui.Mod.Input.Type.InputM (InputM)
import Web.HTML.HTMLElement (focus)
import Inter.Ui.Mod.Input.Util (ref)
import Data.Traversable (for_)
import Effect.Aff (delay)
import Data.Time.Duration (Milliseconds(..))

initialize :: InputM Ɩ
initialize = do
  state <- get
  when state.input.autofocus do
    ʌ' $ delay (Milliseconds 50.0)
    mEl <- getHTMLElementRef ref
    for_ mEl (ʌ ◁ focus)

  debounceRef <- ʌ $ new Nothing

  modify_ _
    { debounceFork = Just debounceRef
    }
