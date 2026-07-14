module Util.Type.Uuid where

import Proem

import Data.Maybe (Maybe(..))
import Data.UUID (UUID, genUUID)
import Data.UUID as UUID
import Effect (Effect)
import Util.Type.String.ToString (class ToString)

newtype Uuid = Uuid String

foreign import _generateV7Uuid :: Effect UUID

generateV7Uuid :: Effect Uuid
generateV7Uuid = do
  uuid <- _generateV7Uuid
  η $ Uuid $ UUID.toString uuid

generateV4Uuid :: Effect Uuid
generateV4Uuid = do
  uuid <- genUUID
  η $ Uuid $ UUID.toString uuid

derive instance Eq Uuid
derive instance Ord Uuid

instance Show Uuid where
  show (Uuid uuid) = "(Uuid " <> uuid <> ")"

instance ToString Uuid where
  toString (Uuid uuid) = uuid

parseUuid :: String -> Maybe Uuid
parseUuid str = case UUID.parseUUID str of
  Just uuid -> Just $ Uuid $ UUID.toString uuid
  Nothing -> Nothing

emptyUuid :: Uuid
emptyUuid = Uuid $ UUID.toString UUID.emptyUUID
