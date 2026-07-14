module Core.Feat.Membership.Process.Index where

import Core.Feat.Membership.Process.OnUserRegistered.AsyncLog2 (AsyncLog2OnUserRegistered)
import Core.Feat.Membership.Process.OnUserRegistered.Log2 (Log2OnUserRegistered)
import Core.Feat.Membership.Process.OnUserRegistered.AsyncLog (AsyncLogOnUserRegistered)
import Core.Feat.Membership.Process.OnUserRegistered.Log (LogOnUserRegistered)

type MembershipProcessRow r =
  ( asyncLogOnUserRegistered :: AsyncLogOnUserRegistered
  , asyncLog2OnUserRegistered :: AsyncLog2OnUserRegistered
  , logOnUserRegistered :: LogOnUserRegistered
  , log2OnUserRegistered :: Log2OnUserRegistered
  | r
  )
