module Inter.Ui.Router.Menu.Core.Search.Results.Item.Core.Content.Content where

import Proem

import Core.Message.Query.Result (Return(..))
import Core.Feat.Review.Message.Query.SearchArticles.Result (Article)
import Halogen.HTML (HTML)
import Inter.Ui.Router.Menu.Core.Search.Results.Item.Core.Content.Style (content_)
import Inter.Ui.Router.Menu.Core.Search.Results.Item.Core.TextWithMatchingWords.TextWithMatchingWords (textWithMatchingWords)
import Util.Type.String.ToString (toString)

import Data.Array as Array
import Data.Maybe (Maybe(..))

content :: ∀ w i. { excerptSearches :: Array String, articleAuthorTokens :: Array String, bookAuthorTokens :: Array String } -> Article -> HTML w i
content normSearches { lead, content: content' } =
  let
    str =
      if Array.length normSearches.excerptSearches > 0 then
        case content' of
          Given c -> toString c
          _ -> case lead of
            Given l -> case l.lead of
              Given (Just h) -> toString h
              _ -> ""
            _ -> ""
      else
        case lead of
          Given l -> case l.lead of
            Given (Just h) -> toString h
            _ -> case content' of
              Given c -> toString c
              _ -> ""
          _ -> case content' of
            Given c -> toString c
            _ -> ""
  in
    content_ [ textWithMatchingWords normSearches.excerptSearches str ]
