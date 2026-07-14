module Core.Feat.Membership.Message.Command.TrackUserDonated.Decide where

import Proem hiding (append)

import Core.Event.Event (Event(..))
import Core.Exception.Index (EXCEPT_LOGIC)
import Core.Mod.Trace.Trace (READER_TRACE)
import Core.Feat.Membership.Message.Command.TrackUserDonated.Payload (Payload)
import Core.Feat.Membership.Message.Command.TrackUserDonated.State (State)
import Run (Run)
import Type.Row (type (+))

decide
  :: ∀ fx
   . State
  -> Payload
  -> Run (EXCEPT_LOGIC + READER_TRACE + fx) (Array Event)
decide state { email, donatedAt, amount } = do
  if state.alreadyExists then η []
  else η [ UserDonated { thirdPartyEmail: email, donatedAt, amount } ]
