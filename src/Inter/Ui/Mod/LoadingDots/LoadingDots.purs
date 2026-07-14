module Inter.Ui.Mod.LoadingDots.LoadingDots
  ( loadingDots
  ) where

import Halogen (ComponentHTML)
import Inter.Ui.Mod.LoadingDots.Style.Style (loadingDots_)
import Inter.Ui.Mod.LoadingDots.Type (Input)
import Inter.Ui.UiM (UiM)

loadingDots :: ∀ action slots. Input -> ComponentHTML action slots UiM
loadingDots input = loadingDots_ input
