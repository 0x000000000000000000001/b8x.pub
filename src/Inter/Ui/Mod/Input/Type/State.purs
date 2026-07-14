module Inter.Ui.Mod.Input.Type.State where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)
import Data.Maybe (Maybe)
import Effect.Ref (Ref)
import Halogen (ForkId)
import Inter.Ui.Mod.Input.Type.Input (Input)
import Inter.Ui.Type.ControlledState (ControlledState(..))
import Inter.Ui.Type.State (WithId)

type State = WithId
  (input :: Input
  , value :: ControlledState String
  , focused :: Boolean
  , debounceFork :: Maybe (Ref (Maybe ForkId))
  )

isOpen :: State -> Boolean
isOpen state = state.focused || value_ /= ""
  where
  value_ = case state.value of
    Controlled v -> v
    Uncontrolled v -> v

value' = π :: Π "value"

_value :: Lens' State (ControlledState String)
_value = prop value'
