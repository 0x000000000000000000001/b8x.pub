module Inter.Ui.Mod.Loader.Loader
  (loader
  ) where

import Proem hiding (div)

import Inter.Ui.Mod.Loader.Animation.Style (animation_)
import Inter.Ui.Mod.Loader.Style.Style (loader_)
import Inter.Ui.Mod.Loader.Style.Index (sheet)
import Inter.Ui.Mod.Loader.Type (Input)
import Inter.Ui.UiM (UiM)
import Halogen (ComponentHTML)

loader :: ∀ action slots. Input -> ComponentHTML action slots UiM
loader color =
  loader_
    [ sheet color
    , animation_ color
    ]
