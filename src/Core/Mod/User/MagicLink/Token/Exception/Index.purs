module Core.Mod.User.MagicLink.Token.Exception.Index where

import Core.Mod.User.MagicLink.Token.Exception.InvalidOrExpiredToken (InvalidOrExpiredTokenRow)
import Core.Mod.User.MagicLink.Token.Exception.AlreadyLoggedInSameUser (AlreadyLoggedInSameUserRow)

type MagicLinkTokenExceptionRow r =
  InvalidOrExpiredTokenRow
    ( AlreadyLoggedInSameUserRow
        r
    )
