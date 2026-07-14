module Util.Type.String.ToString where

import Proem

import Data.Maybe (Maybe(..))
import Data.String.NonEmpty.Internal (NonEmptyString)

-- To
class ToString a where
  toString :: a -> String

instance ToString String where
  toString = identity

instance ToString Int where
  toString = show

instance ToString Number where
  toString = show

instance ToString Boolean where
  toString = show

instance ToString NonEmptyString where
  toString = show

instance (ToString a) => ToString (Maybe a) where
  toString Nothing = "Nothing"
  toString (Just a) = toString a

-- From

class FromString a where
  fromString :: String -> Maybe a

instance FromString String where
  fromString = Just
