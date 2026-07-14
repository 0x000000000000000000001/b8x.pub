module Core.Mod.User.Id.Id
  (UserId
  , module Core.Mod.Id.Id
  ) where

import Core.Mod.Id.Id (make)
import Core.Mod.Id.Id as Id
import Core.Mod.User.User (User)

type UserId = Id.Id User
