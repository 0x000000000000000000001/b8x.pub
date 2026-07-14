module Core.Event.UserUnregistered.Payload where

import Core.Mod.User.Id.Id (UserId)

type Payload =
  { user :: UserId
  }
