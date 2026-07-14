module Inter.Ui.Mod.Newsletter.Component
  ( component
  ) where

import Halogen as H
import Inter.Ui.Mod.Newsletter.HandleAction.Index (handleAction)
import Inter.Ui.Mod.Newsletter.Render (render)
import Inter.Ui.Mod.Newsletter.State (initialState)
import Inter.Ui.Mod.Newsletter.Type (Input, Output, Query)
import Inter.Ui.UiM (UiM)

component :: H.Component Query Input Output UiM
component =
  H.mkComponent
    { initialState
    , render
    , eval: H.mkEval (H.defaultEval { handleAction = handleAction })
    }
