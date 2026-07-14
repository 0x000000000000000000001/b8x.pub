module Core.Feat.Review.Message.Command.FeatureArticleOnFrontPage.Play where

import Core.Event.Event (LoadedEvent)
import Core.Feat.Review.Message.Command.FeatureArticleOnFrontPage.State (State)

play :: State -> LoadedEvent -> State
play _ _ = {}
