module Core.Message.Command.Make where

import Proem

import Core.Message.Command.Command (class IsCommand)
import Core.Message.Field.Payload (class MakePayload, makePayload)
import Foreign (Foreign)
import Data.Newtype (wrap)
import Foreign.Object (Object)
import Core.Message.MakeMessageM (MakeMessageM)

makeCommand
  :: ∀ @cmd state fields payload a
   . IsCommand cmd state fields payload a
  => MakePayload fields payload
  => Object Foreign
  -> MakeMessageM cmd
makeCommand json = wrap <$> makePayload @fields json
