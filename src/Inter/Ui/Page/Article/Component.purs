module Inter.Ui.Page.Article.Component
  (component
  , article_
  , article
  ) where

import Proem

import Data.Maybe (Maybe(..))
import Network.RemoteData (RemoteData(..))
import Halogen (ComponentHTML, Slot, Component, defaultEval, mkComponent, mkEval)
import Inter.Ui.Page.Article.HandleAction.Index (handleAction)
import Inter.Ui.Page.Article.Render (render)
import Inter.Ui.Page.Article.Type (Action(..), Input, Query, Output)
import Inter.Ui.Type.Slot (NoSlotAddressIndex, noSlotAddressIndex)
import Data.Symbol (class IsSymbol)
import Prim.Row (class Cons)
import Halogen.HTML (slot)
import Inter.Ui.Type.State (withId)
import Inter.Ui.UiM (UiM)

component :: Component Query Input Output UiM
component = mkComponent
  { initialState: withId \input ->
      { input
      , article: NotAsked
      , cachedInfo: Nothing
      , relatedArticles: NotAsked
      , issueArticles: NotAsked
      }
  , render
  , eval: mkEval defaultEval
      { handleAction = handleAction
      , initialize = Just Initialize
      , receive = Just ◁ Receive
      }
  }

article_
  :: ∀ @label action slots slotAddressIndex
   . Cons label (Slot Query Output slotAddressIndex) _ slots
  => IsSymbol label
  => Ord slotAddressIndex
  => Input
  -> slotAddressIndex
  -> (Output -> action)
  -> ComponentHTML action slots UiM
article_ input slotAddressIndex handler =
  slot
    (π @label)
    slotAddressIndex
    component
    input
    handler

type SlotsWithArticle slots = (article :: Slot Query Output NoSlotAddressIndex | slots)

article
  :: ∀ action slots
   . Input
  -> (Output -> action)
  -> ComponentHTML action (SlotsWithArticle slots) UiM
article input handler =
  article_
    @"article"
    input
    noSlotAddressIndex
    handler
