module Core.Feat.Review.Message.Command.WriteArticle.Play where

import Proem
import Core.Event.Event (Event(..), LoadedEvent)
import Core.Feat.Review.Message.Command.WriteArticle.State (State)
import Core.Mod.Article.State as Article
import Core.Mod.Author.State as Author
import Core.Mod.Book.State as Book
import Data.Map as Map
import Data.Maybe (Maybe(..))

play :: State -> LoadedEvent -> State
play { author, books, article } e =
  { author: author <#> flip Author.play e
  , books: case e.event of
      BookReferenced payload -> Map.update (Just ◁ flip Book.play e) payload.id books
      BookDereferenced payload -> Map.update (Just ◁ flip Book.play e) payload.book books
      _ -> books
  , article: Article.play article e
  }
