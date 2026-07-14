module Core.Feat.Review.Message.Command.AddArticleToNewsRelatedBlacklist.Result where

import Proem

import Core.Event.Event (Event)
import Core.Exception.Index (EXCEPT_LOGIC)
import Core.Feat.Review.Message.Command.AddArticleToNewsRelatedBlacklist.Payload (Payload)
import Core.Feat.Review.Message.Command.AddArticleToNewsRelatedBlacklist.State (State)
import Run (Run)
import Type.Row (type (+))

type Result = {}

toResult :: ∀ fx. Payload -> State -> Array Event -> Run (EXCEPT_LOGIC + fx) Result
toResult _ _ _ = η {}
