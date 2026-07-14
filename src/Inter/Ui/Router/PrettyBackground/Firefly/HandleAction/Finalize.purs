module Inter.Ui.Router.PrettyBackground.Firefly.HandleAction.Finalize (finalize) where

import Proem

import Data.Foldable (for_)
import Halogen (get)
import Inter.Ui.Router.PrettyBackground.Firefly.Type (FireflyM)

finalize :: FireflyM Ɩ
finalize = do
  { cleanup } <- get
  for_ cleanup ʌ
