module Util.Type.Limit
  ( Limit(..)
  , fromMaybe
  , toMaybe
  ) where

import Proem

import Data.Generic.Rep (class Generic)
import Data.Maybe (Maybe(..))
import Util.Json.TaggedSum (genericReadImplWithDefaultOpt, genericWriteImplWithDefaultOpt)
import Yoga.JSON (class ReadForeign, class WriteForeign)

data Limit a = Infinite | Finite a

derive instance Eq a => Eq (Limit a)
derive instance Generic (Limit a) _
derive instance Functor Limit

instance Show a => Show (Limit a) where
  show Infinite = "Infinite"
  show (Finite n) = "(Finite " <> show n <> ")"

instance WriteForeign a => WriteForeign (Limit a) where
  writeImpl = genericWriteImplWithDefaultOpt

instance ReadForeign a => ReadForeign (Limit a) where
  readImpl = genericReadImplWithDefaultOpt

fromMaybe :: ∀ a. Maybe a -> Limit a
fromMaybe Nothing = Infinite
fromMaybe (Just a) = Finite a

toMaybe :: ∀ a. Limit a -> Maybe a
toMaybe Infinite = Nothing
toMaybe (Finite a) = Just a
