module Inter.Ui.Router.Menu.Core.Items.Item.Label.Label where

import Proem hiding (top, div)

import Halogen (ComponentHTML)
import Halogen.HTML (text)
import Inter.Ui.Router.Menu.Core.Items.Item.Label.Style (label_)
import Inter.Ui.UiM (UiM)

label :: ∀ action slots. String -> ComponentHTML action slots UiM
label l = label_ [ text l ]
