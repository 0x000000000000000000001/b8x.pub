module Core.Feat.Review.Message.Command.AddArticleToNewsRelatedWhitelist.Play where

import Core.Event.Event (LoadedEvent)
import Core.Event.Event as Event
import Core.Feat.Review.Message.Command.AddArticleToNewsRelatedWhitelist.State (State(..))

play :: State -> LoadedEvent -> State
play state { event } = case state, event of
  _, Event.ArticleAddedToNewsRelatedWhitelist _ -> Added
  _, Event.ArticleRemovedFromNewsRelatedWhitelist _ -> Removed
  _, _ -> state
