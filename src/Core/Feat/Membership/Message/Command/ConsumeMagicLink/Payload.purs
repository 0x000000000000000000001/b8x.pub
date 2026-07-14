module Core.Feat.Membership.Message.Command.ConsumeMagicLink.Payload where

import Core.Mod.User.MagicLink.Token.Message.Field.Token (TokenField, Token)

type Fields =
  ( token :: TokenField
  )

type Payload =
  { token :: Token
  }
