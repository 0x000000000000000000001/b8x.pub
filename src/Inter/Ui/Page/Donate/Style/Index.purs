module Inter.Ui.Page.Donate.Style.Index where

import Halogen.HTML.CSS (stylesheet)
import Inter.Ui.Page.Donate.Style.Style (staticStyle)
import Halogen.HTML (HTML)

sheet :: ∀ w i. HTML w i
sheet = stylesheet staticStyle
