module Core.Mod.Newsletter.Id.Id
  (NewsletterId
  , module Core.Mod.Id.Id
  ) where

import Core.Mod.Id.Id (make)
import Core.Mod.Id.Id as Id
import Core.Mod.Newsletter.Newsletter (Newsletter)

type NewsletterId = Id.Id Newsletter
