module Inter.Ui.Router.Menu.Core.Search.Results.Item.Core.TextWithMatchingWords.MatchingWord.MatchingWord
  (matchingWord
  ) where

import Proem hiding (div)

import Halogen.HTML (HTML, text)
import Inter.Ui.Router.Menu.Core.Search.Results.Item.Core.TextWithMatchingWords.MatchingWord.Style (matchingWord_)

matchingWord :: ∀ w i. String -> HTML w i
matchingWord str = matchingWord_ [ text str ]
