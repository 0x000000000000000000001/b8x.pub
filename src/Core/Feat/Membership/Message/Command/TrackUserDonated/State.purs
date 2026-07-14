module Core.Feat.Membership.Message.Command.TrackUserDonated.State where

import Core.Feat.Membership.Message.Command.TrackUserDonated.Payload (Payload)

type State = { alreadyExists :: Boolean }

initialState :: Payload -> State
initialState _ = { alreadyExists: false }
