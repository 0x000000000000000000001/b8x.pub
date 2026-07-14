module Core.Event.UserEmailChanged.Payload where

import Core.Mod.Email.Email (Email)
import Core.Mod.User.Id.Id (UserId)

type Payload =
  { user :: UserId
  , email :: Email
  }
