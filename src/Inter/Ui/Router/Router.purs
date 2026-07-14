module Inter.Ui.Router.Router
  (router
  ) where

import Proem

import Inter.Ui.Router.Component as RouterComponent
import Inter.Ui.Router.Type (Input, Output, Query)
import Inter.Ui.UiM (UiM)
import Data.Symbol (class IsSymbol)
import Halogen (Slot, ComponentHTML)
import Halogen.HTML (slot)
import Prim.Row (class Cons)

router
  :: ∀ @label action slots slotAddressIndex
   . Cons label (Slot Query Output slotAddressIndex) _ slots
  => IsSymbol label
  => Ord slotAddressIndex
  => slotAddressIndex
  -> Input
  -> (Output -> action)
  -> ComponentHTML action slots UiM
router slotAddressIndex input outputAction =
  slot
    (π @label)
    slotAddressIndex
    RouterComponent.component
    input
    outputAction
