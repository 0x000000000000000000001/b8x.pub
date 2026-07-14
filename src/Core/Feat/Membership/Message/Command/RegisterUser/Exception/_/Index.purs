module Core.Feat.Membership.Message.Command.RegisterUser.Exception.Index where

import Core.Feat.Membership.Message.Command.RegisterUser.Exception.UserCannotRegister (UserCannotRegisterRow)
import Type.Row (type (+))

type RegisterUserExceptionRow r =
  UserCannotRegisterRow
    + r
