module Inter.Ui.Router.Menu.Component where

import Proem hiding (top, div)

import Data.Maybe (Maybe(..))
import Data.Symbol (class IsSymbol)
import Halogen (Slot, ComponentHTML, Component, defaultEval, mkComponent, mkEval)
import Halogen.HTML (slot)
import Inter.Ui.Router.Menu.HandleAction.Index (handleAction)
import Inter.Ui.Router.Menu.HandleQuery (handleQuery)
import Inter.Ui.Router.Menu.Render (render)
import Inter.Ui.Router.Menu.Type.Action (Action(..))
import Inter.Ui.Router.Menu.Type.Input (Input)
import Inter.Ui.Router.Menu.Type.Output (Output)
import Inter.Ui.Router.Menu.Type.Query (Query)
import Inter.Ui.Type.ControlledProp as ControlledProp
import Inter.Ui.Type.ControlledState as ControlledState
import Inter.Ui.Type.Slot (NoSlotAddressIndex, noSlotAddressIndex)
import Inter.Ui.Type.State (withId)
import Inter.Ui.UiM (UiM)
import Network.RemoteData (RemoteData(..))
import Prim.Row (class Cons)
import Inter.Ui.Router.Menu.Type.State.Newsletter as Newsletter
import Inter.Ui.Router.Menu.Type.State.Magazine as Magazine
import Halogen.Store.Connect (connect)
import Halogen.Store.Select (selectEq)

component :: Component Query Input Output UiM
component = connect (selectEq _.me) $ mkComponent
  { initialState: withId
      \{ context, input: { open, activePanel, search } } ->
        let
          controlledOpen = case open of
            ControlledProp.Controlled o -> ControlledState.Controlled o
            ControlledProp.Uncontrolled o -> ControlledState.Uncontrolled o
          controlledActivePanel = case activePanel of
            ControlledProp.Controlled a -> ControlledState.Controlled a
            ControlledProp.Uncontrolled a -> ControlledState.Uncontrolled a
          controlledState = case search of
            ControlledProp.Controlled c' -> ControlledState.Controlled { query: c'.query, withAuthorFilter: c'.withAuthorFilter }
            ControlledProp.Uncontrolled c' -> ControlledState.Uncontrolled { query: c'.query, withAuthorFilter: c'.withAuthorFilter }
        in
          { open: controlledOpen
          , activePanel: controlledActivePanel
          , search:
              { controlled: controlledState
              , forkId: Nothing
              , results: NotAsked
              , authorFilter: Nothing
              }
          , newsletter:
              { page: Newsletter.Years
              , calendar: NotAsked
              , articles: NotAsked
              }
          , magazine:
              { page: Magazine.Years
              , calendar: NotAsked
              , articles: NotAsked
              }
          , isDocMouseMoveThrottled: false
          , hasMouseEntered: Nothing
          , me: context
          }
  , render
  , eval: mkEval defaultEval
      { initialize = Just Initialize
      , handleAction = handleAction
      , handleQuery = handleQuery
      , receive = Just ◁ Receive
      }
  }

menu_
  :: ∀ @label action slots slotAddressIndex
   . Cons label (Slot Query Output slotAddressIndex) _ slots
  => IsSymbol label
  => Ord slotAddressIndex
  => Input
  -> (Output -> action)
  -> slotAddressIndex
  -> ComponentHTML action slots UiM
menu_ input handleAction slotAddressIndex =
  slot
    (π @label)
    slotAddressIndex
    component
    input
    handleAction

type SlotsWithMenu slots = (menu :: Slot Query Output NoSlotAddressIndex | slots)

menu
  :: ∀ action slots
   . Input
  -> (Output -> action)
  -> ComponentHTML action (SlotsWithMenu slots) UiM
menu input handleAction =
  menu_
    @"menu"
    input
    handleAction
    noSlotAddressIndex
