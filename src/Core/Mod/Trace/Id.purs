module Core.Mod.Trace.Id
  ( Append
  , AppendId
  , Run
  , RunId
  ) where

import Core.Mod.Id.Id (Id)

data Run
data Append

type RunId = Id Run
type AppendId = Id Append
