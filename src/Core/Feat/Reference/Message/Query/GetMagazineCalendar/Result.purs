module Core.Feat.Reference.Message.Query.GetMagazineCalendar.Result where

import Core.Mod.Image.Message.Query.Result as Result
import Core.Mod.MagazineIssue.Id.Id (MagazineIssueId)
import Core.Mod.MagazineIssue.Number.Number (IssueNumber)
import Core.Mod.MagazineIssue.Slug.Slug (Slug)
import Core.Mod.Time.Year (Year)
import Core.Mod.MagazineIssue.ReleasedAt.ReleasedAt (ReleasedAt)
import Data.Map (Map)
import Data.Map as Map
import Prelude
import Data.Newtype (class Newtype)
import Data.Maybe (Maybe)
import Yoga.JSON (class ReadForeign, class WriteForeign, writeImpl, readImpl)
import Control.Monad.Except (ExceptT)
import Data.Tuple (Tuple(..))

type MagazineIssue =
  { id :: MagazineIssueId
  , name :: String
  , number :: IssueNumber
  , slug :: Slug
  , cover :: Maybe Result.Image
  , releasedAt :: Maybe ReleasedAt
  }

newtype Result = Result
  { calendar :: Map Year (Array MagazineIssue)
  }

instance WriteForeign Result where
  writeImpl (Result r) = writeImpl { calendar: map (\(Tuple y m) -> Tuple y m) (Map.toUnfoldable r.calendar) :: Array (Tuple Year (Array MagazineIssue)) }

instance ReadForeign Result where
  readImpl f = do
    arr <- readImpl f :: ExceptT _ _ { calendar :: Array (Tuple Year (Array MagazineIssue)) }
    pure (Result { calendar: Map.fromFoldable arr.calendar })

derive instance Newtype Result _
