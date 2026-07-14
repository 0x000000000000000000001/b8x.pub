module Inter.Ui.Router.WarningBanner.WarningBanner
  (warningBanner
  ) where

import Proem hiding (div)

import Halogen.HTML (HTML, text)
import Inter.Ui.Router.WarningBanner.Style.Style as Style

warningBanner :: ∀ w i. HTML w i
warningBanner =
  Style.warningBanner_
    [ text "Le site est en chantier. Toute incohérence ou laideur est normale et temporaire. La priorité va à la l'infrastructure invisibible (e.g. données) et à la structure (avec un habillage minimaliste). L'habillage se perfectionnera à la fin des travaux. Bonne visite !" ]
