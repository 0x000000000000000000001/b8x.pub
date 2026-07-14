module Inter.Ui.Mod.Separator.Separator
  (separator
  ) where

import Proem hiding (div)

import Halogen (ComponentHTML)
import Inter.Ui.Mod.Separator.Style.Style (separator_)
import Inter.Ui.Mod.Separator.Text.Text as Text
import Inter.Ui.Mod.Separator.Type (Input)
import Inter.Ui.UiM (UiM)

separator :: ∀ action slots. Input -> ComponentHTML action slots UiM
separator { loading, textElementTag, text } =
  separator_ loading
    [ Text.text textElementTag text
    ]
