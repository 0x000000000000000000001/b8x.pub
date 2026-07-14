module Core.Feat.Reference.Message.Exception.Index where

import Core.Feat.Reference.Message.Command.Exception.Index (ReferenceCommandExceptionRow)
import Core.Feat.Reference.Message.Query.Exception.Index (ReferenceQueryExceptionRow)
import Type.Row (type (+))

type ReferenceMessageExceptionRow r =
  ReferenceCommandExceptionRow
    + ReferenceQueryExceptionRow
    + r
