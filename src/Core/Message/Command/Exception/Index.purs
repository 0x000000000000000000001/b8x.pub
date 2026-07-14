module Core.Message.Command.Exception.Index where

import Core.Message.Command.Handle.Exception (CommandHandleExceptionRow)
import Type.Row (type (+))

type CommandExceptionRow r =
  CommandHandleExceptionRow
    + r