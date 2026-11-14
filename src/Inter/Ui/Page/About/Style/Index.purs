module Inter.Ui.Page.About.Style.Index where

import Halogen.HTML.CSS (stylesheet)
import Inter.Ui.Page.About.Style.Style (staticStyle)
import Halogen.HTML (HTML)

sheet :: ∀ w i. HTML w i
sheet = stylesheet staticStyle
