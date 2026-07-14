module Core.Feat.Review.Message.Command.QuoteArticle.Play where

import Core.Event.Event (LoadedEvent)
import Core.Feat.Review.Message.Command.QuoteArticle.State (State)
import Core.Mod.Article.State as Article

play :: State -> LoadedEvent -> State
play = Article.play
