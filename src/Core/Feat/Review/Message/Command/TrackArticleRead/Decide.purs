module Core.Feat.Review.Message.Command.TrackArticleRead.Decide where

import Proem hiding (append)

import Core.Event.Event (Event(..))
import Core.Exception.Exception (throw)
import Core.Exception.Index (EXCEPT_LOGIC)
import Core.Mod.Trace.Trace (READER_TRACE, askSubject)
import Core.Mod.Trace.Subject (Subject(..))
import Core.Feat.Review.Message.Command.TrackArticleRead.Payload (Payload)
import Core.Feat.Review.Message.Command.TrackArticleRead.State (State)
import Core.Feat.Review.Message.Command.TrackArticleRead.Exception.ArticleReadCannotBeTracked (ArticleReadCannotBeTracked(..))
import Core.Mod.Article.State as Article
import Run (Run)
import Type.Row (type (+))
import Data.Maybe (Maybe(..))

decide
  :: ∀ fx
   . State
  -> Payload
  -> Run (EXCEPT_LOGIC + READER_TRACE + fx) (Array Event)
decide (Article.Written _) { id } = do
  mSubject <- askSubject
  case mSubject of
    Just (AnonymousUiHuman _) -> η [ ArticleRead { id } ]
    Just (IdentifiedUiHuman _) -> η [ ArticleRead { id } ]
    _ -> η []
decide _ _ = throw ArticleReadCannotBeTracked
