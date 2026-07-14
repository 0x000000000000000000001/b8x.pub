module Inter.Ui.Mod.Input.Component
  (component
  , input_
  , input
  ) where

import Proem

import Data.Maybe (Maybe(..))
import Data.Symbol (class IsSymbol)
import Halogen (ComponentHTML, Component, Slot, defaultEval, mkComponent, mkEval)
import Halogen.HTML (slot)
import Inter.Ui.Mod.Input.HandleAction.Index (handleAction)
import Inter.Ui.Mod.Input.HandleQuery (handleQuery)
import Inter.Ui.Mod.Input.Render (render)
import Inter.Ui.Mod.Input.Type.Action (Action(..))
import Inter.Ui.Mod.Input.Type.Input (Input)
import Inter.Ui.Mod.Input.Type.Output (Output)
import Inter.Ui.Mod.Input.Type.Query (Query)
import Inter.Ui.Mod.Input.Type.Value (ControlledValue(..), When(..))
import Inter.Ui.Type.ControlledState as ControlledState
import Inter.Ui.Type.Slot (NoSlotAddressIndex, noSlotAddressIndex)
import Inter.Ui.Type.State (withId)
import Inter.Ui.UiM (UiM)
import Prim.Row (class Cons)

component :: Component Query Input Output UiM
component = mkComponent
  { initialState: withId \input'@{ value } ->
      { input: input'
      , value: case value of
          Controlled v -> ControlledState.Controlled v
          Uncontrolled (OnceChanged _) v -> ControlledState.Controlled v
          Uncontrolled Rightaway v -> ControlledState.Uncontrolled v
      , focused: false
      , debounceFork: Nothing
      }
  , render
  , eval: mkEval defaultEval
      { handleAction = handleAction
      , handleQuery = handleQuery
      , receive = Just ◁ Receive
      , initialize = Just Initialize
      }
  }

input_
  :: ∀ @label action slots slotAddressIndex
   . Cons label (Slot Query Output slotAddressIndex) _ slots
  => IsSymbol label
  => Ord slotAddressIndex
  => Input
  -> (Output -> action)
  -> slotAddressIndex
  -> ComponentHTML action slots UiM
input_ input' outputAction slotAddressIndex =
  slot
    (π @label)
    slotAddressIndex
    component
    input'
    outputAction

type SlotsWithInput slots = (input :: Slot Query Output NoSlotAddressIndex | slots)

input
  :: ∀ action slots
   . Input
  -> (Output -> action)
  -> ComponentHTML action (SlotsWithInput slots) UiM
input input' outputAction =
  input_
    @"input"
    input'
    outputAction
    noSlotAddressIndex
