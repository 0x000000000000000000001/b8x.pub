module Inter.Ui.Mod.Input.Label.Label
  (label
  ) where

import Proem hiding (div)

import Halogen (ComponentHTML)
import Halogen.HTML (text)
import Halogen.HTML.Events (onClick, onMouseDown)
import Inter.Ui.Mod.Input.Label.Style as Style
import Inter.Ui.Mod.Input.Type.Action (Action(..))
import Inter.Ui.Mod.Input.Type.Slots (Slots)
import Inter.Ui.Mod.Input.Type.State (State, isOpen)
import Inter.Ui.Type.Html (noHtml)
import Inter.Ui.UiM (UiM)

label :: State -> ComponentHTML Action Slots UiM
label state@{ input: { label: label' } } =
  label'
    ??
      (\l ->
          Style.label
            (isOpen state
                ?
                  [ onClick HandleLabelClick
                  , onMouseDown HandleLabelMouseDown
                  ]
                ↔ []
            )
            [ text l ]
      )
    ⇔ noHtml
