module Core.Feat.Membership.Message.Query.GetUserAccount.Payload where

import Core.Feat.Membership.Message.Query.GetUserAccount.Field.Needs (Needs, NeedsField)
import Core.Mod.User.Id.Message.Field.TargetUser (TargetUser, TargetUserField)

type Payload =
  { user :: TargetUser
  , needs :: Needs
  }

type Fields =
  ( user :: TargetUserField
  , needs :: NeedsField
  )
