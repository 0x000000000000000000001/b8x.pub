module Inter.Ui.Router.PrettyBackground.Firefly.Firefly
  (firefly
  ) where

import Proem hiding (div)

import Halogen (ComponentHTML)
import Inter.Ui.Router.PrettyBackground.Firefly.Component as FireflyComponent
import Inter.Ui.Router.Type (Action, Slots, State)
import Inter.Ui.UiM (UiM)

firefly :: State -> ComponentHTML Action Slots UiM
firefly _ = FireflyComponent.firefly
