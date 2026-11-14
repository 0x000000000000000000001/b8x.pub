module Inter.Ui.Router.WarningBanner.WarningBanner
  ( warningBanner
  ) where

import Proem hiding (div)

import Halogen.HTML (HTML, text)
import Inter.Ui.Router.WarningBanner.Style.Style as Style

warningBanner :: ∀ w i. HTML w i
warningBanner =
  Style.warningBanner_
    [ text "" ]
