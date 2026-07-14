module Core.Feat.Membership.Message.Command.TrackUserDonated.Result where

import Proem

import Core.Event.Event (Event(..))
import Core.Exception.Exception (throw)
import Core.Exception.Index (EXCEPT_LOGIC)
import Core.Feat.Membership.Message.Command.TrackUserDonated.Exception.UserDonatedCannotBeTracked (UserDonatedCannotBeTracked(..))
import Core.Feat.Membership.Message.Command.TrackUserDonated.Payload (Payload)
import Core.Feat.Membership.Message.Command.TrackUserDonated.State (State)
import Core.Mod.Email.Message.Field (Email)
import Core.Mod.Time.Message.Field.Instant (Instant)
import Data.Array (head)
import Data.Maybe (Maybe(..))
import Run (Run)
import Type.Row (type (+))

type Result = { email :: Email, donatedAt :: Instant, amount :: Int }

toResult :: ∀ fx. Payload -> State -> Array Event -> Run (EXCEPT_LOGIC + fx) Result
toResult _ _ events =
  case head events of
    Just (UserDonated { thirdPartyEmail, donatedAt, amount }) -> η { email: thirdPartyEmail, donatedAt, amount }
    _ -> throw UserDonatedCannotBeTracked
