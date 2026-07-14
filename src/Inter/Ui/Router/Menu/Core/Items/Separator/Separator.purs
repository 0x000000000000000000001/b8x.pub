module Inter.Ui.Router.Menu.Core.Items.Separator.Separator where

import Proem hiding (top, div)

import Halogen (ComponentHTML)
import Inter.Ui.Router.Menu.Core.Items.Separator.Style (separator_)
import Inter.Ui.UiM (UiM)

separator :: ∀ action slots. ComponentHTML action slots UiM
separator = separator_ []
