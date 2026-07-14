module Core.Feat.Review.Message.Command.FeatureArticleOnFrontPage.Decide where

import Proem hiding (append)

import Core.Event.Event (Event(..))
import Core.Exception.Index (EXCEPT_LOGIC)
import Core.Message.Command.Handle.Upload (UPLOAD)
import Core.Feat.Review.Message.Command.FeatureArticleOnFrontPage.Payload (Payload)
import Core.Feat.Review.Message.Command.FeatureArticleOnFrontPage.State (State)
import Run (Run)
import Type.Row (type (+))

decide
  :: ∀ fx
   . State
  -> Payload
  -> Run (UPLOAD + EXCEPT_LOGIC + fx) (Array Event)
decide _ { article, position, theme } = η [ ArticleFeaturedOnFrontPage { article, position, theme } ]
