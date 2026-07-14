module Core.Mod.User.Exception.Index where

import Core.Mod.User.Exception.UserAlreadyRegistered (UserAlreadyRegisteredRow)
import Core.Mod.User.Exception.UserNotRegistered (UserNotRegisteredRow)
import Core.Mod.User.MagicLink.Token.Exception.Index (MagicLinkTokenExceptionRow)
import Type.Row (type (+))

type UserExceptionRow r =
  UserAlreadyRegisteredRow
    + UserNotRegisteredRow
    + MagicLinkTokenExceptionRow
    + r