module Core.Feat.Membership.Message.Query.GetUserAccount.Result where

import Core.Mod.Email.Email (Email)
import Core.Message.Query.Result (Return) as QueryResult

type Result =
  { email :: Email
  , adFree :: QueryResult.Return Boolean
  , hasPaidLastYear :: QueryResult.Return Boolean
  }
