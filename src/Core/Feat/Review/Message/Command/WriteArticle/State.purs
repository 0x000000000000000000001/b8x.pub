module Core.Feat.Review.Message.Command.WriteArticle.State where

import Proem

import Core.Feat.Review.Message.Command.WriteArticle.Payload as WriteArticle
import Core.Mod.Author.State as Author
import Core.Mod.Book.State as Book
import Core.Mod.Article.State as Article
import Core.Mod.Book.Id.Id (BookId)
import Data.Maybe (Maybe)
import Data.Map (Map)
import Data.Map as Map
import Data.Tuple (Tuple(..))

type State =
  { article :: Article.State Ɩ
  , books :: Map BookId (Book.State Ɩ)
  , author :: Maybe (Author.State Ɩ)
  }

initialState :: WriteArticle.Payload -> State
initialState { books, author } =
  { article: Article.initialState
  , books: Map.fromFoldable (books <#> \id -> Tuple id Book.NotReferencedYet)
  , author: author <#> (κ Author.NotReferencedYet)
  }
