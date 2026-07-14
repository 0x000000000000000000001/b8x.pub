module Core.Feat.Review.Message.Command.TrackArticleRead.Play where

import Core.Event.Event (LoadedEvent)
import Core.Feat.Review.Message.Command.TrackArticleRead.State (State)
import Core.Mod.Article.State as Article

play :: State -> LoadedEvent -> State
play = Article.play
