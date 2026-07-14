module Core.Feat.Review.Message.Command.TrackArticleRead.Result where

import Proem

import Core.Event.Event (Event(..))
import Core.Exception.Exception (throw)
import Core.Exception.Index (EXCEPT_LOGIC)
import Core.Feat.Review.Message.Command.TrackArticleRead.Exception.ArticleReadCannotBeTracked (ArticleReadCannotBeTracked(..))
import Core.Feat.Review.Message.Command.TrackArticleRead.Payload (Payload)
import Core.Feat.Review.Message.Command.TrackArticleRead.State (State)
import Core.Mod.Article.Id.Message.Field.Id (Id)
import Data.Array (head)
import Data.Maybe (Maybe(..))
import Run (Run)
import Type.Row (type (+))

type Result = { id :: Id }

toResult :: ∀ fx. Payload -> State -> Array Event -> Run (EXCEPT_LOGIC + fx) Result
toResult _ _ events =
  case head events of
    Just (ArticleRead { id }) -> η { id }
    _ -> throw ArticleReadCannotBeTracked
