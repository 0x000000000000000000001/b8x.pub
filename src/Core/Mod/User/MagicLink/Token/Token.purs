module Core.Mod.User.MagicLink.Token.Token where

import Core.Mod.Token.Token as Base

data MagicLink

type Token = Base.Token MagicLink

