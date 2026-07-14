module Inter.Ui.Router.PrettyBackground.PrettyBackground where

import Proem hiding (div)

import Halogen (ComponentHTML)
import Inter.Ui.Router.PrettyBackground.Firefly.Firefly (firefly)
import Inter.Ui.Router.PrettyBackground.Style.Style (prettyBackground_)
import Inter.Ui.Router.Type (Action, Slots, State)
import Inter.Ui.UiM (UiM)
import Util.Power (isPowerful)

prettyBackground :: State -> ComponentHTML Action Slots UiM
prettyBackground s = prettyBackground_ $ if isPowerful then [ firefly s ] else []
