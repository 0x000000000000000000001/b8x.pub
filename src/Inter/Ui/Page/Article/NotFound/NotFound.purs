module Inter.Ui.Page.Article.NotFound.NotFound
  (notFound
  ) where

import Halogen.HTML (HTML, text)
import Halogen.HTML.Properties (src)
import Inter.Ui.Page.Article.NotFound.Style.Style as Style

notFound :: ∀ w i. HTML w i
notFound = Style.container_
  [ Style.image_ [ src "/asset/image/sad.masquotte.png" ]
  , Style.text_ [ text "Introuvable..." ]
  ]
