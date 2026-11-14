module Inter.Ui.Page.Article.Books.Books
  ( books
  ) where

import Proem

import Core.Message.Query.Result (Fold(..), Return(..))
import Data.Array as Array
import Data.Enum (fromEnum)
import Data.Maybe (Maybe(..))
import Data.Newtype (unwrap)
import Halogen (ComponentHTML)
import Halogen.HTML (text)
import Inter.Ui.Page.Article.Books.Author.Author (author)
import Inter.Ui.Page.Article.Books.Style as Style
import Inter.Ui.Page.Article.Hero.Illustration.Image.Image (image)
import Inter.Ui.Page.Article.Type (Action, State)
import Inter.Ui.Type.Model (UiArticle, UiBook)
import Inter.Ui.UiM (UiM)
import Util.Html.Clean.Clean (untagOnly)
import Util.Html.Clean.Render.Render (SanitizedHtmlString(..), render)

books :: ∀ slots. State -> UiArticle -> ComponentHTML Action slots UiM
books state article = case article.books of
  Given (Unfolded bookList)
    | Array.length bookList > 0 ->
        Style.booksContainer_ state.id
          [ Style.watermark_ state.id [ text (if Array.length bookList > 1 then "LES LIVRES" else "LE LIVRE") ]
          , Style.sectionTitle_ state.id [ text (if Array.length bookList > 1 then "Les Livres" else "Le Livre") ]
          , Style.booksList_ state.id (bookList <#> renderBook state)
          ]
  _ -> text ""

renderBook :: ∀ slots. State -> UiBook -> ComponentHTML Action slots UiM
renderBook state book =
  Style.bookCard_ state.id
    [ Style.bookCover_ state.id
        [ case book.cover of
            Given (Just coverImage) -> case coverImage.src of
              Given src -> image { id: state.id } src true
              _ -> text ""
            _ -> text ""
        ]
    , Style.bookInfo_ state.id
        [ case book.name of
            Given name -> Style.bookTitle_ state.id [ render (SanitizedHtmlString (untagOnly ["p"] true (unwrap name))) ]
            _ -> text ""
        , case book.authors of
            Given authorsList -> Style.bookAuthors_ state.id (Array.intercalate [ text ", " ] (authorsList <#> \bookAuthor -> [ author state bookAuthor ]))
            _ -> text ""
        , case book.editor of
            Given (Just editorName) -> Style.bookEditor_ state.id [ render editorName ]
            _ -> text ""
        , case book.year of
            Given (Just y) -> Style.bookYear_ state.id [ text (if (unwrap y).approximately then "vers " <> show (fromEnum (unwrap (unwrap y).year)) else show (fromEnum (unwrap (unwrap y).year))) ]
            _ -> text ""
        ]
    ]
