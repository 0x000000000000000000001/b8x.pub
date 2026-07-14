module Core.Feat.Membership.Message.Command.UnregisterUser.Payload where

import Core.Mod.User.Id.Message.Field.User (User, UserField)

type Payload =
  { user :: User
  }

type Fields =
  (user :: UserField
  )
