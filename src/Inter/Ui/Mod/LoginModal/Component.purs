module Inter.Ui.Mod.LoginModal.Component (component) where

import Proem

import Halogen (Component, defaultEval, mkComponent, mkEval)
import Inter.Ui.Mod.LoginModal.HandleAction.Index (handleAction)
import Inter.Ui.Mod.LoginModal.HandleQuery.Index (handleQuery)
import Inter.Ui.Mod.LoginModal.Render (render)
import Inter.Ui.Mod.LoginModal.State (initialState)
import Inter.Ui.Mod.LoginModal.Type (Action(..), Output, Query)
import Inter.Ui.UiM (UiM)
import Data.Maybe (Maybe(..), isJust)
import Halogen.Store.Connect (connect)
import Halogen.Store.Select (selectEq)

component :: Component Query {} Output UiM
component = connect (selectEq (\s -> isJust s.me)) $ mkComponent
  { initialState
  , render
  , eval: mkEval defaultEval
      { handleAction = handleAction
      , handleQuery = handleQuery
      , initialize = Just Initialize
      , receive = Just ◁ Receive
      }
  }
