module Inter.Ui.Router.Menu.Core.Search.Results.Item.Core.TextWithMatchingWords.Style.Index where

import Proem

import CSS as CSS
import Inter.Ui.Router.Menu.Core.Search.Results.Item.Core.TextWithMatchingWords.Style.Style as TextWithMatchingWords
import Inter.Ui.Router.Menu.Core.Search.Results.Item.Core.TextWithMatchingWords.MatchingWord.Style as MatchingWord

staticStyle :: CSS.CSS
staticStyle = do
  MatchingWord.staticStyle
  TextWithMatchingWords.staticStyle
