module Inter.Ui.Mod.Input.Type.Input where

import Data.Maybe (Maybe(..))
import Inter.Ui.Mod.Input.Type.Value (ControlledValue(..), When(..), DetectionWay(..))
import Inter.Ui.Mod.Input.Type.Style (Style, defaultStyle)

import Inter.Ui.Mod.Input.Type.Theme (Theme(..))

type Input =
  { placeholder :: Maybe String
  , label :: Maybe String
  , value :: ControlledValue String
  , style :: Style
  , debounceMs :: Number
  , theme :: Theme
  , autofocus :: Boolean
  , helper :: Maybe String
  }

defaultInput :: Input
defaultInput =
  { placeholder: Nothing
  , label: Nothing
  , value: Uncontrolled (OnceChanged ByEvent) ""
  , style: defaultStyle
  , debounceMs: 300.0
  , theme: Default
  , autofocus: false
  , helper: Nothing
  }
