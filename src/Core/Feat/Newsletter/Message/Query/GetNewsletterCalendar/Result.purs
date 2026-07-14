module Core.Feat.Newsletter.Message.Query.GetNewsletterCalendar.Result where

import Core.Mod.Time.Month (Month)
import Core.Mod.Time.Year (Year)

import Core.Mod.Newsletter.Id.Id (NewsletterId)
import Core.Mod.Time.Instant (Instant)
import Data.Map (Map)
import Data.Map as Map
import Prelude
import Data.Newtype (class Newtype)
import Yoga.JSON (class ReadForeign, class WriteForeign, writeImpl, readImpl)
import Control.Monad.Except (ExceptT)
import Data.Tuple (Tuple(..))

newtype Result = Result
  { calendar :: Map Year (Map Month (Array { id :: NewsletterId, scheduledFor :: Instant }))
  }

instance WriteForeign Result where
  writeImpl (Result r) = writeImpl { calendar: map (\(Tuple y m) -> Tuple y (Map.toUnfoldable m)) (Map.toUnfoldable r.calendar) :: Array (Tuple Year (Array (Tuple Month (Array { id :: NewsletterId, scheduledFor :: Instant })))) }

instance ReadForeign Result where
  readImpl f = do
    arr <- readImpl f :: ExceptT _ _ { calendar :: Array (Tuple Year (Array (Tuple Month (Array { id :: NewsletterId, scheduledFor :: Instant })))) }
    let mapped = map (\(Tuple y arr2) -> Tuple y (Map.fromFoldable arr2)) arr.calendar
    pure (Result { calendar: Map.fromFoldable mapped })

derive instance Newtype Result _
