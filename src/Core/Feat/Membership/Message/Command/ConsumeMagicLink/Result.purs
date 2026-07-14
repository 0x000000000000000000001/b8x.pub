module Core.Feat.Membership.Message.Command.ConsumeMagicLink.Result where

import Proem
import Core.Mod.User.Id.Id (UserId)
import Core.Mod.Email.Email (Email, unsafeFromString)
import Core.Event.Event (Event)
import Core.Feat.Membership.Message.Command.ConsumeMagicLink.Payload (Payload)
import Core.Feat.Membership.Message.Command.ConsumeMagicLink.State (State)
import Run (Run)
import Core.Mod.Id.Id as Id

type Result =
  { userId :: UserId
  , email :: Email
  }

toResult :: ∀ fx. Payload -> State -> Array Event -> Run fx Result
toResult _ _ _ = η { userId: Id.unsafeGenerate ι, email: unsafeFromString "" }
