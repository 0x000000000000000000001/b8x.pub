module Core.Mod.Article.Author.Author where

import Core.Mod.Author.Id.Id (AuthorId)
import Data.Maybe (Maybe)

type Author_ = AuthorId

type Author = Maybe Author_
