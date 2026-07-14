module Inter.Ui.Router.Menu.Core.Search.Results.Item.Core.Title.Title where

import Core.Message.Query.Result (Return(..))
import Core.Feat.Review.Message.Query.SearchArticles.Result (Article)
import Halogen.HTML (HTML)
import Inter.Ui.Router.Menu.Core.Search.Results.Item.Core.TextWithMatchingWords.TextWithMatchingWords (textWithMatchingWords)
import Inter.Ui.Router.Menu.Core.Search.Results.Item.Core.Title.Style (title_)
import Util.Type.String.ToString (toString)

title :: ∀ w i. { excerptSearches :: Array String, articleAuthorTokens :: Array String, bookAuthorTokens :: Array String } -> Article -> HTML w i
title normSearches { title: title' } =
  let
    str = case title' of
      Given t -> toString t
      _ -> "Sans titre"
  in
    title_ [ textWithMatchingWords normSearches.excerptSearches str ]
