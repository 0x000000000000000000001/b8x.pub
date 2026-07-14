module Core.Feat.Membership.Message.Command.TrackUserDonated.Play where

import Core.Feat.Membership.Message.Command.TrackUserDonated.State (State)

import Core.Event.Event (Event(..), LoadedEvent)

play :: State -> LoadedEvent -> State
play state { event } = case event of
  UserDonated _ -> state { alreadyExists = true }
  _ -> state
