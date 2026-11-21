module Core.Feat.Review.Message.Command.CorrectArticle.Play where

import Proem

import Core.Event.Event (Event(..), LoadedEvent)
import Core.Feat.Review.Message.Command.CorrectArticle.State (State)
import Core.Mod.Article.State as Article

play :: State -> LoadedEvent -> State
play state { event } = case event of
  ArticleWritten { title, lead, content } -> state { article = Article.Written { title, lead, content } }
  ArticleDiscarded _ -> state { article = Article.Discarded }
  ArticleTitleCorrected { title } -> state { article = state.article <#> (_ { title = title }) }
  ArticleLeadCorrected { lead } -> state { article = state.article <#> (_ { lead = lead }) }
  ArticleContentCorrected { content } -> state { article = state.article <#> (_ { content = content }) }

  _ -> state
