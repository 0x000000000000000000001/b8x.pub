module Inter.Ui.Page.Home.Component
  (component
  , home_
  , home
  ) where

import Proem

import Data.Maybe (Maybe(..))
import Data.Symbol (class IsSymbol)
import Halogen (ComponentHTML, Component, Slot, defaultEval, mkComponent, mkEval)
import Halogen.HTML (slot)
import Inter.Ui.Page.Home.HandleAction.Index (handleAction)
import Inter.Ui.Page.Home.Render (render)
import Inter.Ui.Page.Home.Type (Action(..), Input, Query, Output)
import Inter.Ui.Type.Output (noOutputAction)
import Inter.Ui.Type.Slot (NoSlotAddressIndex, noSlotAddressIndex)
import Inter.Ui.Type.State (withId)
import Inter.Ui.UiM (UiM)
import Network.RemoteData (RemoteData(..))
import Prim.Row (class Cons)

component :: Component Query Input Output UiM
component = mkComponent
  { initialState: withId \input ->
      { frontPage: NotAsked
      , articleQuote: NotAsked
      , newsArticles: NotAsked
      , mostReadArticles: NotAsked
      , newsletterArticles: NotAsked
      , bandsForkId: Nothing
      , lastTriggeredFrontPageIds: Nothing
      , input
      }
  , render
  , eval: mkEval defaultEval
      { handleAction = handleAction
      , initialize = Just Load
      , receive = Just ◁ Receive
      }
  }

home_
  :: ∀ @label action slots slotAddressIndex
   . Cons label (Slot Query Output slotAddressIndex) _ slots
  => IsSymbol label
  => Ord slotAddressIndex
  => slotAddressIndex
  -> Input
  -> ComponentHTML action slots UiM
home_ slotAddressIndex input =
  slot
    (π @label)
    slotAddressIndex
    component
    input
    noOutputAction

type SlotsWithHome slots = (home :: Slot Query Output NoSlotAddressIndex | slots)

home
  :: ∀ action slots
   . Input
  -> ComponentHTML action (SlotsWithHome slots) UiM
home input =
  home_
    @"home"
    noSlotAddressIndex
    input