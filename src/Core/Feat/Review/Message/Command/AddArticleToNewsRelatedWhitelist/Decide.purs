module Core.Feat.Review.Message.Command.AddArticleToNewsRelatedWhitelist.Decide where

import Proem

import Core.Event.Event (Event(..))
import Core.Exception.Index (EXCEPT_LOGIC)
import Core.Feat.Review.Message.Command.AddArticleToNewsRelatedWhitelist.Payload (Payload)
import Core.Feat.Review.Message.Command.AddArticleToNewsRelatedWhitelist.State (State(..))
import Run (Run)
import Type.Row (type (+))

decide
  :: ∀ fx
   . State
  -> Payload
  -> Run (EXCEPT_LOGIC + fx) (Array Event)
decide NotAddedYet { article } = η [ ArticleAddedToNewsRelatedWhitelist { article } ]
decide Removed { article } = η [ ArticleAddedToNewsRelatedWhitelist { article } ]
decide Added _ = η []
