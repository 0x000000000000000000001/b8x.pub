module Core.Message.Exception.Index where

import Core.Message.Command.Exception.Index (CommandExceptionRow)
import Core.Message.Exception.MalformedPayloadValue (MalformedPayloadValueRow)
import Core.Message.Field.Exception.Index (FieldExceptionRow)
import Type.Row (type (+))

type MessageExceptionRow e r =
  CommandExceptionRow
    + FieldExceptionRow e
    + MalformedPayloadValueRow
    + r