module Inter.Ui.Mod.AdPlaceholder.AdPlaceholder
  ( adPlaceholder
  ) where

import Proem hiding (div)

import Halogen (ComponentHTML)
import Halogen.HTML as HH
import Inter.Ui.Mod.AdPlaceholder.Style.Style (adPlaceholder_)
import Inter.Ui.Mod.AdPlaceholder.Type (Input)
import Inter.Ui.UiM (UiM)
import Util.Type.String.ToString (toString)

adPlaceholder :: ∀ action slots. Input -> ComponentHTML action slots UiM
adPlaceholder { width, height, name } =
  adPlaceholder_ width height
    [ HH.text $ name <> " (" <> toString width <> " x " <> toString height <> ")"
    ]
