module Core.Feat.Review.Message.Command.WriteArticle.Result where

import Proem

import Core.Event.Event (Event(..))
import Core.Exception.Exception (throw)
import Core.Exception.Index (EXCEPT_LOGIC)
import Core.Feat.Review.Message.Command.WriteArticle.Exception.ArticleCannotBeWritten (ArticleCannotBeWritten(..))
import Core.Feat.Review.Message.Command.WriteArticle.Payload (Payload)
import Core.Feat.Review.Message.Command.WriteArticle.State (State)
import Core.Mod.Article.Id.Message.Field.AutoId (Id)
import Data.Array (head)
import Data.Maybe (Maybe(..))
import Run (Run)
import Type.Row (type (+))
import Core.Mod.Article.Slug.Slug (Slug)

type Result =
  { id :: Id
  , slug :: Slug
  }

toResult :: ∀ fx. Payload -> State -> Array Event -> Run (EXCEPT_LOGIC + fx) Result
toResult _ _ newEvents =
  case head newEvents of
    Just (ArticleWritten { id, slug }) -> η { id, slug }
    _ -> throw ArticleCannotBeWritten