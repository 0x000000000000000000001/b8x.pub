module Inter.Ui.Router.Menu.Core.Search.Results.Item.Core.TextWithMatchingWords.TextWithMatchingWords
  (normalizeWord
  , textWithMatchingWords
  ) where

import Proem hiding (div)

import Data.Array (any)
import Data.Array as Array
import Data.String (toLower)
import Halogen.HTML (ElemName(..), HTML, element, text)
import Html.Parser (HtmlNode(..), Element, parse)
import Html.Renderer.Halogen (htmlAttributeToProp)
import Inter.Ui.Router.Menu.Core.Search.Results.Item.Core.TextWithMatchingWords.MatchingWord.MatchingWord (matchingWord)
import Inter.Ui.Router.Menu.Core.Search.Results.Item.Core.TextWithMatchingWords.Style.Style (textWithMatchingWords_)
import Util.Type.String.String (Token(..), removeAccents, tokenize)

textWithMatchingWords :: ∀ w i. Array String -> String -> HTML w i
textWithMatchingWords normSearches rawHtml =
  let
    nodes = parse rawHtml
    htmlNodes = Array.concatMap (nodeToHtmlWithMatchingWords normSearches) nodes
  in
    textWithMatchingWords_ htmlNodes

normalizeWord :: String -> String
normalizeWord = toLower ◁ removeAccents

isClose :: String -> Array String -> Boolean
isClose word normSearches =
  let
    normWord = normalizeWord word
    matches s = s /= "" && s == normWord
  in
    any matches normSearches

nodeToHtmlWithMatchingWords :: ∀ p i. Array String -> HtmlNode -> Array (HTML p i)
nodeToHtmlWithMatchingWords normSearches (HtmlElement ele) =
  [ elementToHtmlWithMatchingWords normSearches ele ]
nodeToHtmlWithMatchingWords normSearches (HtmlText str) =
  let
    tokens = tokenize str

    renderToken :: Token -> HTML p i
    renderToken = case _ of
      Separator t -> text t
      Word t ->
        if isClose t normSearches then
          matchingWord t
        else
          text t
  in
    map renderToken tokens
nodeToHtmlWithMatchingWords _ (HtmlComment _) = []

elementToHtmlWithMatchingWords :: ∀ p i. Array String -> Element -> HTML p i
elementToHtmlWithMatchingWords normSearches { name, attributes, children } =
  element
    (ElemName name)
    (Array.fromFoldable $ htmlAttributeToProp <$> attributes)
    (Array.concatMap (nodeToHtmlWithMatchingWords normSearches) children)
