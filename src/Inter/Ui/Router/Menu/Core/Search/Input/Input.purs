module Inter.Ui.Router.Menu.Core.Search.Input.Input where

import Proem hiding (div)

import Color as CSS
import Data.Maybe (Maybe(..))
import Halogen (ComponentHTML)
import Inter.Ui.Mod.Input.Component as Component
import Inter.Ui.Mod.Input.Type.Input (defaultInput)
import Inter.Ui.Mod.Input.Type.Style (defaultStyle)
import Inter.Ui.Mod.Input.Type.Value (DetectionWay(..), ControlledValue(..), When(..))
import Inter.Ui.Router.Menu.Core.Search.Input.Style (input_)
import Inter.Ui.Router.Menu.Type.Action (Action(..))
import Inter.Ui.Router.Menu.Type.Slots (Slots)
import Inter.Ui.Router.Menu.Type.State.State (State)
import Inter.Ui.Type.ControlledState as ControlledState
import Inter.Ui.UiM (UiM)
import Data.Array as Array
import Inter.Ui.Router.Menu.Core.Search.AuthorFilter.AuthorFilter as AuthorFilter

input :: State -> ComponentHTML Action Slots UiM
input state@{ search: { controlled, authorFilter } } =
  let
    queryValue = case controlled of
      ControlledState.Controlled c -> c.query
      ControlledState.Uncontrolled c -> c.query
  in
    input_ state
      ( [ Component.input_ @"searchInput"
            (defaultInput
                { label = Just "Recherchez..."
                , placeholder = Just case authorFilter of
                    Just _ -> "Titre, livre ou sujet..."
                    Nothing -> "Titre, auteur, livre ou sujet..."
                , debounceMs = 250.0
                , value = Uncontrolled (OnceChanged ByEvent) queryValue
                , style = defaultStyle
                    { backgroundColor = Just (CSS.rgba 0 0 0 0.0) -- Transparent
                    , textColor = Just CSS.black
                    , placeholderColor = Just (CSS.rgba 0 0 0 0.5)
                    , border =
                        defaultStyle.border
                          { color = Just (CSS.rgba 0 0 0 0.0)
                          , width =
                              { top: Just 0.0
                              , right: Just 0.0
                              , bottom: Just 0.0
                              , left: Just 0.0
                              }
                          }
                    }
                }
            )
            HandleSearchInputOutput
            ι
        ] <> Array.catMaybes [ AuthorFilter.authorFilter state ]
      )
