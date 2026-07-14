module Inter.Ui.Mod.Input.Field.Field
  (field
  ) where

import Proem hiding (div)

import Data.Array ((:))
import Halogen (ComponentHTML)
import Halogen.HTML.Events (onBlur, onFocus, onValueInput)
import Halogen.HTML.Properties as HP
import Halogen.HTML.Properties as Ref
import Inter.Ui.Mod.Input.Field.Style as Style
import Inter.Ui.Mod.Input.Type.Action (Action(..))
import Inter.Ui.Mod.Input.Type.Slots (Slots)
import Inter.Ui.Mod.Input.Type.State (State, isOpen)
import Inter.Ui.Mod.Input.Util (ref)
import Inter.Ui.Type.ControlledState (ControlledState(..))
import Inter.Ui.UiM (UiM)

field :: State -> ComponentHTML Action Slots UiM
field state@{ id, value, input: { placeholder } } =
  Style.field id
    ([ Ref.ref ref
      , onValueInput HandleUserInput
      , onFocus $ κ HandleFocus
      , onBlur $ κ HandleBlur
      , HP.value $ case value of
          Controlled val -> val
          Uncontrolled val -> val
      , HP.autofocus state.input.autofocus
      ]
        <>
          (isOpen state
              ? (placeholder ?? (HP.placeholder ▷ (_ : [])) ⇔ [])
              ↔ []
          )
    )
