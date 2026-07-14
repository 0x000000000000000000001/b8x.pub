module Core.Feat.Membership.Message.Command.RegisterUser.Result where

import Proem

import Core.Event.Event (Event(..))
import Core.Exception.Exception (throw)
import Core.Exception.Index (EXCEPT_LOGIC)
import Core.Feat.Membership.Message.Command.RegisterUser.Exception.UserCannotRegister (UserCannotRegister(..))
import Core.Feat.Membership.Message.Command.RegisterUser.Payload (Payload)
import Core.Feat.Membership.Message.Command.RegisterUser.State (State)
import Core.Mod.User.Id.Message.Field.AutoId (Id)
import Data.Array (head)
import Data.Maybe (Maybe(..))
import Run (Run)
import Type.Row (type (+))

type Result = { id :: Id }

toResult :: ∀ fx. Payload -> State -> Array Event -> Run (EXCEPT_LOGIC + fx) Result
toResult _ _ events =
  case head events of
    Just (UserRegistered { id }) -> η { id }
    _ -> throw UserCannotRegister