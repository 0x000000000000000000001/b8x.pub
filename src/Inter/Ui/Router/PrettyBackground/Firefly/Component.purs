module Inter.Ui.Router.PrettyBackground.Firefly.Component
  (component
  , firefly_
  , firefly
  ) where

import Proem

import Data.Maybe (Maybe(..))
import Data.Symbol (class IsSymbol)
import Halogen (ComponentHTML, Component, Slot, defaultEval, mkComponent, mkEval)
import Halogen.HTML (slot)
import Inter.Ui.Router.PrettyBackground.Firefly.HandleAction.Index (handleAction)
import Inter.Ui.Router.PrettyBackground.Firefly.Render (render)
import Inter.Ui.Router.PrettyBackground.Firefly.Type (Action(..), Input, Query, Output)
import Inter.Ui.Type.Input (noInput)
import Inter.Ui.Type.Output (noOutputAction)
import Inter.Ui.Type.Slot (NoSlotAddressIndex, noSlotAddressIndex)
import Inter.Ui.UiM (UiM)
import Prim.Row (class Cons)

component :: Component Query Input Output UiM
component = mkComponent
  { initialState: κ
      { cleanup: Nothing
      }
  , render
  , eval: mkEval defaultEval
      { handleAction = handleAction
      , initialize = Just Initialize
      , finalize = Just Finalize
      }
  }

firefly_
  :: ∀ @label action slots slotAddressIndex
   . Cons label (Slot Query Output slotAddressIndex) _ slots
  => IsSymbol label
  => Ord slotAddressIndex
  => slotAddressIndex
  -> ComponentHTML action slots UiM
firefly_ slotAddressIndex =
  slot
    (π @label)
    slotAddressIndex
    component
    noInput
    noOutputAction

type SlotsWithFirefly slots = (firefly :: Slot Query Output NoSlotAddressIndex | slots)

firefly
  :: ∀ action slots
  . ComponentHTML action (SlotsWithFirefly slots) UiM
firefly =
  firefly_
    @"firefly"
    noSlotAddressIndex
