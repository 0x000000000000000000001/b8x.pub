module Inter.Ui.Type.Children where

import Halogen (ComponentHTML)
import Inter.Ui.UiM (UiM)

type Children action slots = Array (ComponentHTML action slots UiM)
