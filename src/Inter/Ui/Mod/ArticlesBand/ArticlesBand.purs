module Inter.Ui.Mod.ArticlesBand.ArticlesBand
  (articlesBand
  , articlesBand_
  ) where

import Proem hiding (div)

import Halogen.HTML (HTML, text)
import Inter.Ui.Mod.ArticlesBand.Style as Style

type Input =
  { title :: String
  }

articlesBand :: ∀ w i. Input -> Array (HTML w i) -> HTML w i
articlesBand { title } children =
  Style.articlesBand_
    [ Style.title_ [ text title ]
    , Style.content_ (children # map \child -> Style.articleContainer_ [ child ])
    ]

articlesBand_ :: ∀ w i. Input -> HTML w i
articlesBand_ i = articlesBand i []
