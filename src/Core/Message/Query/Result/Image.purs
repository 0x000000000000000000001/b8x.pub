module Core.Message.Query.Result.Image where

import Core.Message.Query.Result (Return)

type Image =
  { src :: Return Src
  }

type Src = String
