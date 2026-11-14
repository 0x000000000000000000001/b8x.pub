module Inter.Ui.Page.Legal.Style.Index where

import Halogen.HTML.CSS (stylesheet)
import Inter.Ui.Page.Legal.Style.Style (staticStyle)
import Halogen.HTML (HTML)

sheet :: ∀ w i. HTML w i
sheet = stylesheet staticStyle
