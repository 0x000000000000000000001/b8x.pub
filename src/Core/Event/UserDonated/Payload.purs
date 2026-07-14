module Core.Event.UserDonated.Payload where

import Core.Mod.Email.Message.Field (Email)
import Core.Mod.Time.Message.Field.Instant (Instant)

type Payload =
  { thirdPartyEmail :: Email
  , donatedAt :: Instant
  , amount :: Int
  }
