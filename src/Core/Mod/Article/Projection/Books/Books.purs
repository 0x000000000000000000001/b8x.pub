module Core.Mod.Article.Projection.Books.Books where

import Foreign as Foreign
import Proem
import Foreign.Index as Foreign.Index

import Core.Mod.Author.Id.Id (AuthorId)
import Core.Mod.Author.Name.Name as Author
import Core.Mod.Editor.Name.Name as EditorName
import Core.Mod.Book.Id.Id (BookId)
import Core.Mod.Book.Name.Name as Book
import Core.Mod.Book.Year.Year (Year)
import Core.Mod.Image.Image (Image)
import Data.Maybe (Maybe, isJust)
import Data.Nullable (Nullable, toMaybe)
import Yoga.JSON (class ReadForeign, class WriteForeign, readImpl)
import Foreign (Foreign)
import Data.Traversable (traverse)
import Data.Generic.Rep (class Generic)
import Data.Newtype (class Newtype)
import Util.Type.Random (class Random)
import Data.Array as Array

type Author =
  { id :: AuthorId
  , name :: Author.Name
  }

type Authors = Array Author

type Book =
  { id :: BookId
  , name :: Book.Name
  , year :: Maybe Year
  , cover :: Maybe Image
  , authors :: Authors
  , editor :: Maybe EditorName.Name
  }

newtype Books = Books
  { books :: Array Book
  , ids :: Array BookId
  , names :: Array Book.Name
  , authors ::
      { ids :: Array AuthorId
      , names :: Array Author.Name
      }
  , hasAtLeastOneCover :: Boolean
  }

make :: Array Book -> Books
make books = Books
  { books
  , ids: books <#> _.id
  , names: books <#> _.name
  , authors:
      { ids: (books >>= _.authors) <#> _.id
      , names: (books >>= _.authors) <#> _.name
      }
  , hasAtLeastOneCover: Array.any (isJust ◁ _.cover) books
  }

derive instance Newtype Books _
derive instance Generic Books _
derive instance Eq Books
derive instance Ord Books
derive newtype instance Show Books
derive newtype instance Random Books
derive newtype instance WriteForeign Books

instance ReadForeign Books where
  readImpl json = do
    obj <- readImpl json
    booksJson <- (Foreign.Index.readProp "books" obj >>= readImpl)
    books <- traverse decodeBookJson booksJson
    ids <- (Foreign.Index.readProp "ids" obj >>= readImpl)
    names <- (Foreign.Index.readProp "names" obj >>= readImpl)
    authors <- (Foreign.Index.readProp "authors" obj >>= readImpl)
    hasAtLeastOneCover <- (Foreign.Index.readProp "hasAtLeastOneCover" obj >>= readImpl)
    η $ Books { books, ids, names, authors, hasAtLeastOneCover }

decodeBookJson :: Foreign -> Foreign.F Book
decodeBookJson json = do
  obj <- readImpl json
  id <- (Foreign.Index.readProp "id" obj >>= readImpl)
  name <- (Foreign.Index.readProp "name" obj >>= readImpl)
  year <- (Foreign.Index.readProp "year" obj >>= readImpl)
  cover <- (Foreign.Index.readProp "cover" obj >>= readImpl)
  authorsJson <- (Foreign.Index.readProp "authors" obj >>= readImpl)
  authors <- traverse decodeAuthorJson authorsJson
  editor <- (Foreign.Index.readProp "editor" obj >>= readImpl)
  η { id, name, year, cover, authors, editor }

decodeAuthorJson :: Foreign -> Foreign.F Author
decodeAuthorJson json = do
  obj <- readImpl json
  id <- (Foreign.Index.readProp "id" obj >>= readImpl)
  name <- (Foreign.Index.readProp "name" obj >>= readImpl)
  η { id, name }

type BookAuthorRefDto =
  { id :: AuthorId
  , name :: Author.Name
  }

type BookDto =
  { id :: BookId
  , name :: Book.Name
  , year :: Nullable Year
  , cover :: Nullable Image
  , authors :: Array BookAuthorRefDto
  , editor :: Nullable EditorName.Name
  }

type BooksDto =
  { books :: Array BookDto
  , ids :: Array BookId
  , names :: Array Book.Name
  , authors ::
      { ids :: Array AuthorId
      , names :: Array Author.Name
      }
  , hasAtLeastOneCover :: Boolean
  }

fromBookDto :: BookDto -> Book
fromBookDto dto =
  { id: dto.id
  , name: dto.name
  , year: toMaybe dto.year
  , cover: toMaybe dto.cover
  , authors: dto.authors
  , editor: toMaybe dto.editor
  }

fromBooksDto :: BooksDto -> Books
fromBooksDto dto = Books
  { books: fromBookDto <$> dto.books
  , ids: dto.ids
  , names: dto.names
  , authors: dto.authors
  , hasAtLeastOneCover: dto.hasAtLeastOneCover
  }
