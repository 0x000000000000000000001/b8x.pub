module Core.Feat.Review.Message.Exception.Index where

import Core.Feat.Review.Message.Command.Exception.Index (ReviewCommandExceptionRow)
import Core.Feat.Review.Message.Query.Exception.Index (ReviewQueryExceptionRow)
import Type.Row (type (+))

type ReviewMessageExceptionRow r =
  ReviewCommandExceptionRow
    + ReviewQueryExceptionRow
    + r
