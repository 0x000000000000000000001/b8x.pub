module Inter.Ui.Router.Component
  (component
  ) where

import Inter.Ui.Router.HandleAction.Index (handleAction)
import Inter.Ui.Router.HandleQuery (handleQuery)
import Inter.Ui.Router.Render (render)
import Inter.Ui.Router.Type (Action(..), Input, Output, Query)
import Inter.Ui.UiM (UiM)
import Data.Maybe (Maybe(..))
import Halogen (Component, defaultEval, mkComponent, mkEval)

component :: Component Query Input Output UiM
component = mkComponent
  { initialState: \input ->
      { route: Nothing
      , isUrlLoaded: false
      , scrollFork: Nothing
      , toastEmitter: input.toastEmitter
      , modalEmitter: input.modalEmitter
      }
  , render
  , eval: mkEval defaultEval
      { handleAction = handleAction
      , handleQuery = handleQuery
      , initialize = Just Initialize
      }
  }
