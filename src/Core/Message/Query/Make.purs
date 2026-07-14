module Core.Message.Query.Make where

import Proem

import Core.Message.Query.Query (class IsQuery)
import Core.Message.Field.Payload (class MakePayload, makePayload)
import Foreign (Foreign)
import Data.Newtype (wrap)
import Foreign.Object (Object)
import Core.Message.MakeMessageM (MakeMessageM)

makeQuery
  :: ∀ @query state fields payload result
   . IsQuery query state fields payload result
  => MakePayload fields payload
  => Object Foreign
  -> MakeMessageM query
makeQuery json = wrap <$> makePayload @fields json
