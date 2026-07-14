module Core.Feat.Reference.Exception.Index where

import Core.Feat.Reference.Message.Exception.Index (ReferenceMessageExceptionRow)
import Type.Row (type (+))

type ReferenceExceptionRow r =
  ReferenceMessageExceptionRow
    + r
