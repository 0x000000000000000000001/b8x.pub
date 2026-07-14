module Inter.Ui.Mod.Login.Component
  ( component
  ) where

import Proem

import Halogen as H
import Inter.Ui.Mod.Login.HandleAction.Index (handleAction)
import Inter.Ui.Mod.Login.Render (render)
import Inter.Ui.Mod.Login.State (initialState)
import Inter.Ui.Mod.Login.Type (Input, Output, Query, Action(..))
import Inter.Ui.UiM (UiM)
import Data.Maybe (Maybe(..))

component :: H.Component Query Input Output UiM
component =
  H.mkComponent
    { initialState
    , render
    , eval: H.mkEval (H.defaultEval { handleAction = handleAction, receive = Just ◁ const Initialize })
    }
