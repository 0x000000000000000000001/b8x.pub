module Core.Feat.Review.Message.Command.AddArticleToNewsRelatedBlacklist.Decide where

import Proem

import Core.Event.Event (Event(..))
import Core.Exception.Index (EXCEPT_LOGIC)
import Core.Feat.Review.Message.Command.AddArticleToNewsRelatedBlacklist.Payload (Payload)
import Core.Feat.Review.Message.Command.AddArticleToNewsRelatedBlacklist.State (State(..))
import Run (Run)
import Type.Row (type (+))

decide
  :: ∀ fx
   . State
  -> Payload
  -> Run (EXCEPT_LOGIC + fx) (Array Event)
decide NotAddedYet { article } = η [ ArticleAddedToNewsRelatedBlacklist { article } ]
decide Removed { article } = η [ ArticleAddedToNewsRelatedBlacklist { article } ]
decide Added _ = η []
