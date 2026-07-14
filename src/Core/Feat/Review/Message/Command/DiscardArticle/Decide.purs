module Core.Feat.Review.Message.Command.DiscardArticle.Decide where

import Proem hiding (append)

import Core.Event.Event (Event(..))
import Core.Exception.Exception (throw)
import Core.Exception.Index (EXCEPT_LOGIC)
import Core.Feat.Review.Message.Command.DiscardArticle.Payload (Payload)
import Core.Feat.Review.Message.Command.DiscardArticle.State (State)
import Core.Mod.Article.Exception.ArticleNotWritten (ArticleNotWritten(..))
import Core.Mod.Article.State as Article
import Run (Run)
import Type.Row (type (+))

decide
  :: ∀ fx
   . State
  -> Payload
  -> Run (EXCEPT_LOGIC + fx) (Array Event)
decide Article.NotWrittenYet { article } = throw $ ArticleNotWritten article
decide Article.Discarded { article } = throw $ ArticleNotWritten article
decide (Article.Written _) { article } = η [ ArticleDiscarded { article } ]
