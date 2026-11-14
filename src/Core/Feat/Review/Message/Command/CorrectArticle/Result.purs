module Core.Feat.Review.Message.Command.CorrectArticle.Result where

import Proem

import Core.Event.Event (Event)
import Core.Exception.Index (EXCEPT_LOGIC)
import Core.Feat.Review.Message.Command.CorrectArticle.Payload (Payload)
import Core.Feat.Review.Message.Command.CorrectArticle.State (State)
import Core.Mod.Article.Id.Message.Field.AutoId (Id)
import Run (Run)
import Type.Row (type (+))

type Result = { id :: Id }

toResult :: ∀ fx. Payload -> State -> Array Event -> Run (EXCEPT_LOGIC + fx) Result
toResult { id } _ _ = η { id }
