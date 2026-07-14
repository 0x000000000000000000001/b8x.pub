module Inter.Ui.Mod.Input.Render
  (render
  ) where

import Proem hiding (div)

import Halogen (ComponentHTML)
import Halogen.HTML (div, text)
import Halogen.HTML.Events (onClick)
import Inter.Ui.Mod.Input.Field.Field as Field
import Inter.Ui.Mod.Input.Label.Label as Label
import Inter.Ui.Mod.Input.Style.Index (sheet)
import Inter.Ui.Mod.Input.Style.Style (input)
import Inter.Ui.Mod.Input.Type.Action (Action(..))
import Inter.Ui.Mod.Input.Type.Slots (Slots)
import Inter.Ui.Mod.Input.Type.State (State, isOpen)
import Inter.Ui.UiM (UiM)

import Halogen.HTML.Properties as HP
import Halogen.HTML.Core as H
import Data.Maybe (Maybe(..))

render :: State -> ComponentHTML Action Slots UiM
render s =
  let
    styleAttr = case s.input.style.widthRem of
      Just w -> [ HP.attr (H.AttrName "style") ("width: " <> show w <> "rem; margin: 0 auto;") ]
      Nothing -> []
  in
    div styleAttr
      ([ input s.input.theme (isOpen s)
          [ onClick $ κ HandleClick ]
          [ sheet s
          , Label.label s
          , Field.field s
          ]
       ]
        <> case s.input.helper of
             Just helperStr -> [ div [ HP.attr (H.AttrName "style") "font-size: 0.8rem; opacity: 0.7; margin-top: 0.5rem; text-align: left; padding-left: 0; color: white;" ] [ text helperStr ] ]
             Nothing -> []
      )
