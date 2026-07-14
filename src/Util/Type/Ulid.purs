module Util.Type.Ulid
  ( Ulid
  , generateUlid
  , parseUlid
  , toString
  ) where

import Proem

import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Util.Type.String.ToString (class ToString)

newtype Ulid = Ulid String

foreign import _generateUlid :: Effect String
foreign import _isValid :: String -> Boolean

generateUlid :: Effect Ulid
generateUlid = do
  ulid <- _generateUlid
  η $ Ulid ulid

derive instance Eq Ulid
derive instance Ord Ulid

instance Show Ulid where
  show ulid = "(Ulid " <> toString ulid <> ")"

instance ToString Ulid where
  toString (Ulid ulid) = ulid

parseUlid :: String -> Maybe Ulid
parseUlid str = _isValid str ? (Just $ Ulid str) ↔ Nothing

toString :: Ulid -> String
toString (Ulid ulid) = ulid

derive newtype instance WriteForeign Ulid
derive newtype instance ReadForeign Ulid
