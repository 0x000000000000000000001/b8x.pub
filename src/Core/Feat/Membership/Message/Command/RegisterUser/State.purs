module Core.Feat.Membership.Message.Command.RegisterUser.State where



import Core.Mod.User.State as User
import Core.Feat.Membership.Message.Command.RegisterUser.Payload as RegisterUser

import Core.Mod.User.Id.Id (UserId)

type State = User.State UserId

initialState :: RegisterUser.Payload -> State
initialState _ = User.initialState

