module Inter.Ui.Mod.Link.Component
  (component
  , link_
  , link
  ) where

import Proem

import Data.Maybe (Maybe(..))
import Data.Symbol (class IsSymbol)
import Halogen (ComponentHTML, Component, Slot, defaultEval, mkComponent, mkEval)
import Halogen.HTML (slot)
import Inter.Ui.Mod.Link.HandleAction.Index (handleAction)
import Inter.Ui.Mod.Link.Render (render)
import Inter.Ui.Mod.Link.Type (Action(..), Input, Output, Query)
import Inter.Ui.Type.Slot (NoSlotAddressIndex, noSlotAddressIndex)
import Inter.Ui.Type.State (withId)
import Inter.Ui.UiM (UiM)
import Prim.Row (class Cons)

component :: Component Query Input Output UiM
component = mkComponent
  { initialState: withId \input -> { input }
  , render
  , eval: mkEval defaultEval
      { handleAction = handleAction
      , receive = Just ◁ Receive
      }
  }

link_
  :: ∀ @label action slots slotAddressIndex
   . Cons label (Slot Query Output slotAddressIndex) _ slots
  => IsSymbol label
  => Ord slotAddressIndex
  => Input
  -> (Output -> action)
  -> slotAddressIndex
  -> ComponentHTML action slots UiM
link_ input outputAction slotAddressIndex =
  slot
    (π @label)
    slotAddressIndex
    component
    input
    outputAction

type SlotsWithLink slots = (link :: Slot Query Output NoSlotAddressIndex | slots)

link
  :: ∀ action slots
   . Input
  -> (Output -> action)
  -> ComponentHTML action (SlotsWithLink slots) UiM
link input outputAction =
  link_
    @"link"
    input
    outputAction
    noSlotAddressIndex
