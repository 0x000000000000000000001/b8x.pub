module Inter.Ui.Mod.ArticleCard.Component
  (component
  , articleCard_
  , articleCard
  ) where

import Proem

import Data.Maybe (Maybe(..))
import Data.Symbol (class IsSymbol)
import Halogen (ComponentHTML, Component, Slot, defaultEval, mkComponent, mkEval)
import Halogen.HTML (slot)
import Inter.Ui.Mod.ArticleCard.HandleAction.Index (handleAction)
import Inter.Ui.Mod.ArticleCard.Render (render)
import Inter.Ui.Mod.ArticleCard.Type (Action(..), Input, Output, Query)

import Inter.Ui.Type.State (withId)
import Inter.Ui.UiM (UiM)
import Prim.Row (class Cons)

component :: Component Query Input Output UiM
component = mkComponent
  { initialState: withId \input ->
      { input
      }
  , render
  , eval: mkEval defaultEval
      { handleAction = handleAction
      , initialize = Just Initialize
      , receive = Just ◁ Receive
      }
  }

articleCard_
  :: ∀ @label action slots slotAddressIndex
   . Cons label (Slot Query Output slotAddressIndex) _ slots
  => IsSymbol label
  => Ord slotAddressIndex
  => Input
  -> (Output -> action)
  -> slotAddressIndex
  -> ComponentHTML action slots UiM
articleCard_ input outputAction slotAddressIndex =
  slot
    (π @label)
    slotAddressIndex
    component
    input
    outputAction

type SlotsWithArticleCard slotAddressIndex slots = (articleCard :: Slot Query Output slotAddressIndex | slots)

articleCard
  :: ∀ action slots slotAddressIndex
   . Ord slotAddressIndex
  => Input
  -> (Output -> action)
  -> slotAddressIndex
  -> ComponentHTML action (SlotsWithArticleCard slotAddressIndex slots) UiM
articleCard input outputAction slotAddressIndex =
  articleCard_
    @"articleCard"
    input
    outputAction
    slotAddressIndex
