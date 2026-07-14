module Inter.Ui.Router.Menu.Core.Search.Results.Item.Core.BooksAndAuthors.BooksAndAuthors where

import Proem

import Core.Message.Query.Result (Return(..))
import Core.Message.Query.Result as QueryResult
import Core.Feat.Review.Message.Query.SearchArticles.Result (Article)
import Core.Mod.Book.Message.Query.Result.Books (Book_)
import Data.Array as Array
import Data.Maybe (Maybe(..))
import Data.String as String
import Halogen.HTML (HTML, text)
import Inter.Ui.Router.Menu.Core.Search.Results.Item.Core.BooksAndAuthors.Style (booksAndAuthors_)
import Inter.Ui.Router.Menu.Core.Search.Results.Item.Core.TextWithMatchingWords.TextWithMatchingWords (textWithMatchingWords)
import Util.Type.String.ToString (toString)

booksAndAuthors :: ∀ w i. { excerptSearches :: Array String, articleAuthorTokens :: Array String, bookAuthorTokens :: Array String } -> Article -> HTML w i
booksAndAuthors normSearches { author, books } =
  let
    authorNodes = case author of
      Given (Just { name: Given n }) -> [ text "Par ", textWithMatchingWords (normSearches.excerptSearches <> normSearches.articleAuthorTokens) (toString n) ]
      _ -> []

    bookNodes = case books of
      Given (QueryResult.Unfolded bks) ->
        let
          names = Array.mapMaybe formatBook bks
        in
          case Array.length names of
            0 -> []
            1 -> [ text "Livre : ", textWithMatchingWords (normSearches.excerptSearches <> normSearches.bookAuthorTokens) (String.joinWith ", " names) ]
            _ -> [ text "Livres : ", textWithMatchingWords (normSearches.excerptSearches <> normSearches.bookAuthorTokens) (String.joinWith ", " names) ]
      _ -> []

    combined = case Array.length authorNodes > 0, Array.length bookNodes > 0 of
      true, true -> authorNodes <> [ text " - " ] <> bookNodes
      true, false -> authorNodes
      false, true -> bookNodes
      false, false -> []
  in
    if Array.length combined > 0 then booksAndAuthors_ combined
    else text ""

formatBook :: Book_ -> Maybe String
formatBook { name, authors: aus } =
  let
    bnStr = case name of
      Given bn -> Just ("\"" <> toString bn <> "\"")
      _ -> Nothing
    bauStr = case aus of
      Given aList ->
        let
          auNames = Array.mapMaybe (\{ name: n } -> Just (toString n)) aList
        in
          if Array.length auNames > 0 then Just (String.joinWith ", " auNames) else Nothing
      _ -> Nothing
  in
    case bnStr, bauStr of
      Just bn, Just bau -> Just (bn <> " (" <> bau <> ")")
      Just bn, Nothing -> Just bn
      Nothing, Just bau -> Just bau
      Nothing, Nothing -> Nothing
