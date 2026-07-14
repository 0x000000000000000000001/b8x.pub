module Core.Feat.Review.Message.Command.AddArticleToNewsRelatedBlacklist.Play where

import Core.Event.Event (LoadedEvent)
import Core.Event.Event as Event
import Core.Feat.Review.Message.Command.AddArticleToNewsRelatedBlacklist.State (State(..))

play :: State -> LoadedEvent -> State
play state { event } = case state, event of
  _, Event.ArticleAddedToNewsRelatedBlacklist _ -> Added
  _, Event.ArticleRemovedFromNewsRelatedBlacklist _ -> Removed
  _, _ -> state
