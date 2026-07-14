module Core.Message.Message where

import Util.Type.String.ToString (class ToString)

data Message = Command | Query

instance ToString Message where
  toString Command = "command"
  toString Query = "query"