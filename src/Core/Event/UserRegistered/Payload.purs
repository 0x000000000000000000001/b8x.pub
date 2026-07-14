module Core.Event.UserRegistered.Payload where

import Core.Mod.Email.Email (Email)
import Core.Mod.User.Id.Id (UserId)

type Payload =
  { id :: UserId
  , email :: Email
  }
