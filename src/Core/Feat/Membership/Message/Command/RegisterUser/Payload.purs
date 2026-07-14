module Core.Feat.Membership.Message.Command.RegisterUser.Payload where

import Core.Mod.Email.Message.Field (Email, EmailField)
import Core.Mod.User.Id.Message.Field.AutoId (Id, IdField)

type Payload =
  { id :: Id
  , email :: Email
  }

type Fields =
  (id :: IdField
  , email :: EmailField
  )
