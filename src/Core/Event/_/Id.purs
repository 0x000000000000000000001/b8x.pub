module Core.Event.Id
  ( EventId
  , Event
  , module Core.Mod.Id.Id
  ) where

import Core.Mod.Id.Id (make)
import Core.Mod.Id.Id as Id

data Event

type EventId = Id.Id Event
