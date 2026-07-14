module Core.Feat.Membership.Message.Command.SendMeMagicLink.Result where

import Proem
import Core.Event.Event (Event)
import Core.Feat.Membership.Message.Command.SendMeMagicLink.Payload (Payload)
import Core.Feat.Membership.Message.Command.SendMeMagicLink.State (State)
import Run (Run)

type Result = Ɩ

toResult :: ∀ fx. Payload -> State -> Array Event -> Run fx Result
toResult _ _ _ = η ι
