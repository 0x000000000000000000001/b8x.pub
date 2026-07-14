module Inter.Ui.Mod.Modal.Component
  (component
  , modal_
  , modal
  ) where

import Proem

import Data.Maybe (Maybe(..))
import Data.Symbol (class IsSymbol)
import Halogen (ComponentHTML, Component, Slot, defaultEval, mkComponent, mkEval)
import Halogen.HTML (slot)
import Inter.Ui.Mod.Modal.HandleAction.Index (handleAction)
import Inter.Ui.Mod.Modal.Render (render)
import Inter.Ui.Mod.Modal.Type (Action(..), Input, Output)
import Inter.Ui.Type.Slot (NoSlotAddressIndex, noSlotAddressIndex)
import Inter.Ui.Type.State (withId)
import Inter.Ui.UiM (UiM)
import Prim.Row (class Cons)

component
  :: ∀ q i o
   . Component q i o UiM
  -> Component q (Input i) (Output o) UiM
component innerComponent = mkComponent
  { initialState: withId \input ->
      { input
      }
  , render: render innerComponent
  , eval:
      mkEval
        defaultEval
          { handleAction = handleAction
          , receive = Just ◁ Receive
          , initialize = Just Initialize
          }
  }

modal_
  :: ∀ @label action slots slotAddressIndex query input output
   . Cons label (Slot query (Output output) slotAddressIndex) _ slots
  => IsSymbol label
  => Ord slotAddressIndex
  => Component query input output UiM
  -> Input input
  -> (Output output -> action)
  -> slotAddressIndex
  -> ComponentHTML action slots UiM
modal_ innerComponent input outputAction slotAddressIndex =
  slot
    (π @label)
    slotAddressIndex
    (component innerComponent)
    input
    outputAction

type SlotsWithModal query output slots = (modal :: Slot query (Output output) NoSlotAddressIndex | slots)

modal
  :: ∀ action slots query input output
   . Component query input output UiM
  -> Input input
  -> (Output output -> action)
  -> ComponentHTML action (SlotsWithModal query output slots) UiM
modal innerComponent input outputAction =
  modal_
    @"modal"
    innerComponent
    input
    outputAction
    noSlotAddressIndex
