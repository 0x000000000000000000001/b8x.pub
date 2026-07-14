module Core.Feat.Membership.Message.Command.ChangeUserEmail.Payload where

import Core.Mod.Email.Message.Field (Email, EmailField)
import Core.Mod.User.Id.Message.Field.User (User, UserField)

type Payload =
  { user :: User
  , email :: Email
  }

type Fields =
  (user :: UserField
  , email :: EmailField
  )
