module Inter.Ui.Router.Component
  (component
  ) where

import Proem

import Inter.Ui.Router.HandleAction.Index (handleAction)
import Inter.Ui.Router.HandleQuery (handleQuery)
import Inter.Ui.Router.Render (render)
import Inter.Ui.Router.Type (Action(..), Input, Output, Query)
import Inter.Ui.UiM (UiM)
import Data.Maybe (Maybe(..))
import Halogen (Component, defaultEval, mkComponent, mkEval)
import Halogen.Store.Connect (connect)
import Halogen.Store.Select (selectEq)

component :: Component Query Input Output UiM
component = connect (selectEq _.device) $ mkComponent
  { initialState: \{ input, context } ->
      { route: Nothing
      , isUrlLoaded: false
      , scrollFork: Nothing
      , toastEmitter: input.toastEmitter
      , modalEmitter: input.modalEmitter
      , context
      }
  , render
  , eval: mkEval defaultEval
      { handleAction = handleAction
      , handleQuery = handleQuery
      , initialize = Just Initialize
      , receive = Just <<< Receive
      }
  }
