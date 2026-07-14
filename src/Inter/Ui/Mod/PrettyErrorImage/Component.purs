module Inter.Ui.Mod.PrettyErrorImage.Component
  (component
  , prettyErrorImage_
  , prettyErrorImage
  ) where

import Proem

import Data.Maybe (Maybe(..))
import Data.Symbol (class IsSymbol)
import Halogen (ComponentHTML, Component, Slot, defaultEval, mkComponent, mkEval)
import Halogen.HTML (slot)
import Inter.Ui.Mod.PrettyErrorImage.HandleAction.Index (handleAction)
import Inter.Ui.Mod.PrettyErrorImage.Render (render)
import Inter.Ui.Mod.PrettyErrorImage.Type (Action(..), Input, Output, Query, Try(..))
import Inter.Ui.Type.Output (noOutputAction)
import Inter.Ui.Type.Slot (NoSlotAddressIndex, noSlotAddressIndex)
import Inter.Ui.Type.State (withId)
import Inter.Ui.UiM (UiM)
import Prim.Row (class Cons)

component :: Component Query Input Output UiM
component = mkComponent
  { initialState: withId \input ->
      { input
      , try: FirstTry input.sources.first
      }
  , render
  , eval: mkEval defaultEval
      { handleAction = handleAction
      , receive = Just ◁ Receive
      }
  }

prettyErrorImage_
  :: ∀ @label action slots slotAddressIndex
   . Cons label (Slot Query Output slotAddressIndex) _ slots
  => IsSymbol label
  => Ord slotAddressIndex
  => Input
  -> slotAddressIndex
  -> ComponentHTML action slots UiM
prettyErrorImage_ input slotAddressIndex =
  slot
    (π @label)
    slotAddressIndex
    component
    input
    noOutputAction

type SlotsWithPrettyErrorImage slots = (prettyErrorImage :: Slot Query Output NoSlotAddressIndex | slots)

prettyErrorImage
  :: ∀ action slots
   . Input
  -> ComponentHTML action (SlotsWithPrettyErrorImage slots) UiM
prettyErrorImage input =
  prettyErrorImage_
    @"prettyErrorImage"
    input
    noSlotAddressIndex