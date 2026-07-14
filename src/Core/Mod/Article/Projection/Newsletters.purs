module Core.Mod.Article.Projection.Newsletters where

import Proem
import Foreign.Index as Foreign.Index
import Foreign (Foreign, F)

import Core.Mod.Newsletter.Id.Id (NewsletterId)
import Core.Mod.Time.Instant (Instant)
import Core.Mod.Time.Month (Month)
import Core.Mod.Time.Year as TimeYear
import Yoga.JSON (class ReadForeign, class WriteForeign, readImpl)
import Data.Traversable (traverse)
import Data.Array as Array
import Data.Generic.Rep (class Generic)
import Data.Newtype (class Newtype)
import Data.Maybe (Maybe(..))
import Util.Type.Random (class Random)

type Newsletter =
  { id :: NewsletterId
  , index :: Int
  , scheduledFor ::
      { instant :: Instant
      , month :: Month
      , year :: TimeYear.Year
      }
  }

type MostRecent =
  { scheduledFor :: Instant
  , index :: Int
  }

newtype Newsletters = Newsletters
  { newsletters :: Array Newsletter
  , ids :: Array NewsletterId
  , issues :: Array { month :: Month, year :: TimeYear.Year }
  , hasAtLeastOne :: Boolean
  , mostRecent :: Maybe MostRecent
  }

derive instance Newtype Newsletters _
derive instance Generic Newsletters _
derive instance Eq Newsletters
derive instance Ord Newsletters
derive newtype instance Show Newsletters
derive newtype instance WriteForeign Newsletters

instance ReadForeign Newsletters where
  readImpl json = do
    obj <- readImpl json
    newslettersJson <- Foreign.Index.readProp "newsletters" obj >>= readImpl
    newsletters <- traverse decodeNewsletterJson newslettersJson
    ids <- (Foreign.Index.readProp "ids" obj >>= readImpl)
    issuesJson <- (Foreign.Index.readProp "issues" obj >>= readImpl)
    issues <- traverse decodeIssueJson issuesJson
    hasAtLeastOne <- (Foreign.Index.readProp "hasAtLeastOne" obj >>= readImpl)
    mostRecentJson <- (Foreign.Index.readProp "mostRecent" obj >>= readImpl)
    mostRecent <- decodeMostRecentJson mostRecentJson
    pure $ Newsletters { newsletters, ids, issues, hasAtLeastOne, mostRecent }

decodeNewsletterJson :: forall a278 a286 a306 a314 a322. ReadForeign a278 => ReadForeign a286 => ReadForeign a306 => ReadForeign a314 => ReadForeign a322 => Foreign -> F { id :: a278, index :: a286, scheduledFor :: { instant :: a306, month :: a314, year :: a322 } }
decodeNewsletterJson json = do
  obj <- readImpl json
  id <- (Foreign.Index.readProp "id" obj >>= readImpl)
  index <- (Foreign.Index.readProp "index" obj >>= readImpl)
  scheduledForJson <- (Foreign.Index.readProp "scheduledFor" obj >>= readImpl)
  scheduledForObj <- readImpl scheduledForJson
  instant <- (Foreign.Index.readProp "instant" scheduledForObj >>= readImpl)
  month <- (Foreign.Index.readProp "month" scheduledForObj >>= readImpl)
  year <- (Foreign.Index.readProp "year" scheduledForObj >>= readImpl)
  η { id, index, scheduledFor: { instant, month, year } }

decodeIssueJson :: forall a368 a376. ReadForeign a368 => ReadForeign a376 => Foreign -> F { month :: a368, year :: a376 }
decodeIssueJson json = do
  obj <- readImpl json
  month <- (Foreign.Index.readProp "month" obj >>= readImpl)
  year <- (Foreign.Index.readProp "year" obj >>= readImpl)
  η { month, year }

decodeMostRecentJson :: forall a343 a351. ReadForeign a343 => ReadForeign a351 => Foreign -> F (Maybe { index :: a351, scheduledFor :: a343 })
decodeMostRecentJson json = do
  mObj <- readImpl json
  case mObj of
    Nothing -> pure Nothing
    Just obj -> do
      scheduledFor <- (Foreign.Index.readProp "scheduledFor" obj >>= readImpl)
      index <- (Foreign.Index.readProp "index" obj >>= readImpl)
      η (Just { scheduledFor, index })

instance Random Newsletters where
  random = η $ Newsletters { newsletters: [], ids: [], issues: [], hasAtLeastOne: false, mostRecent: Nothing }

make :: Array Newsletter -> Newsletters
make newsletters_ = Newsletters
  { newsletters: newsletters_
  , ids: newsletters_ <#> _.id
  , issues: newsletters_ <#> \n -> { month: n.scheduledFor.month, year: n.scheduledFor.year }
  , hasAtLeastOne: Array.length newsletters_ > 0
  , mostRecent:
      let
        sorted = Array.sortBy (\a b -> compare a.scheduledFor.instant b.scheduledFor.instant) newsletters_
      in
        Array.last sorted <#> \n -> { scheduledFor: n.scheduledFor.instant, index: n.index }
  }

empty :: Newsletters
empty = make []


