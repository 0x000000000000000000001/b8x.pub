module Inter.Ui.Page.Article.Books.Books
  ( books
  ) where

import Proem hiding (div)
import Core.Message.Query.Result (Fold(..), Return(..))
import Inter.Ui.Type.Model (UiArticle, UiBook)
import Data.Array as Array
import Data.Maybe (Maybe(..))
import Core.Mod.Html.Html as Html
import Data.Newtype (unwrap)
import Data.Enum (fromEnum)
import Inter.Ui.Page.Article.Type (Action(..))
import Halogen.HTML.Events (onClick)
import Halogen.HTML (HTML, text, span)
import Halogen.HTML.Properties (class_)
import Halogen as Halogen
import Util.Html.Clean.Render.Render (render, renderArray)
import Inter.Ui.Page.Article.Books.Style as Style
import Inter.Ui.Page.Article.Hero.Illustration.Image.Image (image)
import Inter.Ui.Type.InstanceId (InstanceId)

books :: ∀ w r. { id :: InstanceId | r } -> UiArticle -> HTML w Action
books state article = case article.books of
  Given (Unfolded bookList)
    | Array.length bookList > 0 ->
        Style.booksContainer_ state.id
          [ Style.watermark_ state.id [ text (if Array.length bookList > 1 then "LES LIVRES" else "LE LIVRE") ]
          , Style.sectionTitle_ state.id [ text (if Array.length bookList > 1 then "Les Livres" else "Le Livre") ]
          , Style.booksList_ state.id (bookList <#> renderBook state.id)
          ]
  _ -> text ""

renderBook :: ∀ p. InstanceId -> UiBook -> HTML p Action
renderBook id book =
  Style.bookCard_ id
    [ Style.bookCover_ id
        [ case book.cover of
            Given (Just img) -> case img.src of
              Given src -> image { id } src true
              _ -> text ""
            _ -> text ""
        ]
    , Style.bookInfo_ id
        [ case book.name of
            Given name -> Style.bookTitle_ id [ render name ]
            _ -> text ""
        , case book.authors of
            Given authorsList -> Style.bookAuthors_ id (Array.intercalate [text ", "] (map (\a -> [ span [ class_ (Halogen.ClassName "authorLink"), onClick \e -> ClickAuthor e { id: a.id, name: Html.unsafeFromString (unwrap a.name), ofBook: true } ] (renderArray a.name) ]) authorsList))
            _ -> text ""
        , case book.editor of
            Given (Just editorName) -> Style.bookEditor_ id [ render editorName ]
            _ -> text ""
        , case book.year of
            Given (Just y) -> Style.bookYear_ id [ text (if (unwrap y).approximately then "vers " <> show (fromEnum (unwrap (unwrap y).year)) else show (fromEnum (unwrap (unwrap y).year))) ]
            _ -> text ""
        ]
    ]
