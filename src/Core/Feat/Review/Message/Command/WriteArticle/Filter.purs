module Core.Feat.Review.Message.Command.WriteArticle.Filter where

import Proem hiding ((&&), (||))

import Core.Event.Filter (Filter(..), false_)
import Core.Feat.Review.Message.Command.WriteArticle.Payload (Payload)
import Core.Mod.Author.State as Author
import Core.Mod.Book.State as Book
import Core.Mod.Article.State as Article
import Data.Foldable (foldl)

filter :: Payload -> Filter
filter { id, author, books } =
  Or
    (Or (Article.filter id) (author ?? Author.filter ⇔ false_))
    (foldl (\acc b -> Or acc (Book.filter b)) false_ books)
