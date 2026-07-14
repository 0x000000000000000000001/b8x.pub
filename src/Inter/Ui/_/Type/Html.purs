module Inter.Ui.Type.Html where

import Halogen.HTML (HTML, text)

noHtml :: ∀ w i. HTML w i
noHtml = text ""
