module Core.Mod.Article.Projection.WrittenAt where

import Proem
import Foreign.Index as Foreign.Index

import Core.Mod.Time.Instant (Instant)
import Core.Mod.Time.Year (Year, fromInstant)
import Yoga.JSON (class ReadForeign, class WriteForeign, readImpl)
import Data.Generic.Rep (class Generic)
import Data.Newtype (class Newtype)
import Util.Type.Random (class Random)

newtype WrittenAt = WrittenAt
  { instant :: Instant
  , year :: Year
  }

derive instance Newtype WrittenAt _
derive instance Generic WrittenAt _
derive instance Eq WrittenAt
derive instance Ord WrittenAt
derive newtype instance Random WrittenAt
derive newtype instance Show WrittenAt
derive newtype instance WriteForeign WrittenAt

instance ReadForeign WrittenAt where
  readImpl json = do
    obj <- readImpl json
    instant <- Foreign.Index.readProp "instant" obj >>= readImpl
    year <- Foreign.Index.readProp "year" obj >>= readImpl
    η $ WrittenAt { instant, year }


make :: Instant -> WrittenAt
make instant = WrittenAt
  { instant
  , year: fromInstant instant
  }


