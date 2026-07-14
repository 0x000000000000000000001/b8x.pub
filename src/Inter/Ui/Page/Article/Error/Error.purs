module Inter.Ui.Page.Article.Error.Error
  (error_
  ) where

import Halogen.HTML (HTML, text)
import Halogen.HTML.Properties (src)
import Inter.Ui.Page.Article.Error.Style.Style as Style

error_ :: ∀ w i. String -> HTML w i
error_ _ = Style.container_
  [ Style.image_ [ src "/asset/image/dead.mascotte.png" ]
  , Style.text_ [ text "Erreur..." ]
  -- , Style.text_ [ text err ]
  ]
