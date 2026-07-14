module Core.Message.Field.Exception.Index where

import Core.Message.Field.Exception.InvalidField (InvalidFieldExceptionRow)
import Core.Message.Field.Exception.MissingField (MissingFieldExceptionRow)
import Type.Row (type (+))

type FieldExceptionRow e r =
  MissingFieldExceptionRow
    + InvalidFieldExceptionRow e
    + r
