module Util.Json.String where

import Proem

import Data.Maybe (Maybe(..))
import Foreign (Foreign, F, ForeignError(..), fail)
import Util.Type.String.ToString (class FromString, class ToString, fromString, toString)
import Yoga.JSON (readImpl, writeImpl)

writeStringImpl :: ∀ a. ToString a => a -> Foreign
writeStringImpl = writeImpl <<< toString

readStringImpl :: ∀ a. FromString a => Foreign -> F a
readStringImpl json = do
  str <- readImpl json
  case fromString str of
    Just v -> pure v
    Nothing -> fail (ForeignError "Unexpected string value")
