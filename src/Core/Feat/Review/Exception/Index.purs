module Core.Feat.Review.Exception.Index where

import Core.Feat.Review.Message.Exception.Index (ReviewMessageExceptionRow)
import Type.Row (type (+))

type ReviewExceptionRow r =
  ReviewMessageExceptionRow
    + r
