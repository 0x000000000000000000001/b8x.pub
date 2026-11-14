module Inter.Ui.Page.Legal.Component where

import Proem

import Inter.Ui.Page.Legal.HandleAction.Index (handleAction)
import Inter.Ui.Page.Legal.Render (render)
import Inter.Ui.Page.Legal.State (initialState)
import Inter.Ui.Page.Legal.Type (Action(..), Output, Query)
import Inter.Ui.UiM (UiM)
import Data.Maybe (Maybe(..), isJust)
import Halogen (Component, defaultEval, mkComponent, mkEval)
import Halogen.Store.Connect (connect)
import Halogen.Store.Select (selectEq)

component :: Component Query {} Output UiM
component = connect (selectEq (\store -> isJust store.me)) $ mkComponent
  { initialState
  , render
  , eval: mkEval defaultEval
      { handleAction = handleAction
      , receive = Just ◁ Receive
      , initialize = Just Initialize
      , finalize = Just Finalize
      }
  }
