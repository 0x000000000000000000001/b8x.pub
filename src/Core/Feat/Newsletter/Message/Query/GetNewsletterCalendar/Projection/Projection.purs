module Core.Feat.Newsletter.Message.Query.GetNewsletterCalendar.Projection.Projection where

import Data.Tuple (Tuple(..))

import Proem hiding (add)
import Control.Monad.Except as Control.Monad.Except

import Core.Event.Event (Event(..), LoadedEvent)
import Core.Event.NewsletterScheduled.Payload as NewsletterScheduled
import Core.Mod.Projection.Finder.Finder (Find, findOneByKey)
import Core.Mod.Projection.Pair (class IsPair, class ToAliasedPrimary)
import Core.Mod.Projection.Projection (class IsProjection, ProjectionWriteOps, add, coerce, get, put)
import Core.Mod.Projection.SyncProject (SyncProject)
import Core.Mod.Time.Instant (Instant(..))
import Core.Mod.Time.Month (Month(..))
import Core.Mod.Time.Year (Year(..))
import Yoga.JSON (class ReadForeign, class WriteForeign, readImpl, writeImpl)
import Data.Array as Array
import Data.Date as Data.Date
import Data.DateTime as Data.DateTime
import Data.DateTime.Instant as Data.DateTime.Instant
import Data.Generic.Rep (class Generic)
import Data.Map (Map)
import Data.Map as Map
import Data.Maybe (Maybe(..), fromMaybe)
import Data.Newtype (class Newtype)
import Core.Mod.Newsletter.Id.Id (NewsletterId)
import Run (Run)
import Safe.Coerce as Safe.Coerce
import Type.Row (type (+))
import Util.Type.Random (class Random)

data GetNewsletterCalendarProjection

instance
  IsProjection
    GetNewsletterCalendarProjection
    "getNewsletterCalendar"
    "getNewsletterCalendarProjectionWriteOps"
    (GET_NEWSLETTER_CALENDAR_PROJECTION_WRITE_OPS ())
    "getNewsletterCalendarProjectionReadSyncProject"
    { calendar :: Calendar }
    { calendar :: CalendarIndexNeeds }
    { calendar :: {} }
  where
  indexNeeds = { calendar: {} }

  play = coerce @(GET_NEWSLETTER_CALENDAR_PROJECTION_WRITE_OPS ()) play

type GET_NEWSLETTER_CALENDAR_PROJECTION_WRITE_OPS fx = (getNewsletterCalendarProjectionWriteOps :: ProjectionWriteOps | fx)
type GET_NEWSLETTER_CALENDAR_PROJECTION_READ_SYNC_PROJECT fx = (getNewsletterCalendarProjectionReadSyncProject :: SyncProject | fx)
type GET_NEWSLETTER_CALENDAR_PROJECTION_READ_FIND fx 
  = GET_NEWSLETTER_CALENDAR_CALENDAR_PROJECTION_READ_FIND
      + fx

-- Model

instance
  IsPair
    CalendarKey
    Calendar
    CalendarRecord
    CalendarIndexNeeds
    ()
    "calendar"
    "calendar"
    "getNewsletterCalendarCalendarProjectionReadFind"
    GetNewsletterCalendarProjection
  where
  toKey _ = CalendarKey

  single = true

newtype Calendar = Calendar CalendarRecord

type CalendarRecord =
  { calendar :: Map Year (Map Month (Array { id :: NewsletterId, scheduledFor :: Instant }))
  }

type CalendarIndexNeeds = {}

derive instance Newtype Calendar _
derive instance Generic Calendar _
derive instance Eq Calendar
derive instance Ord Calendar

instance ReadForeign Calendar where
  readImpl f = do
    arr <- readImpl f :: Control.Monad.Except.ExceptT _ _ (Array (Tuple Year (Array (Tuple Month (Array { id :: NewsletterId, scheduledFor :: Instant })))))
    calendar <- pure (Map.fromFoldable (map (\(Tuple y arr2) -> Tuple y (Map.fromFoldable arr2)) arr))
    pure (Calendar { calendar })



encodeCalendar :: CalendarRecord -> Array (Tuple Year (Array (Tuple Month (Array { id :: NewsletterId, scheduledFor :: Instant }))))
encodeCalendar r = map (\(Tuple y m) -> Tuple y (Map.toUnfoldable m)) (Map.toUnfoldable r.calendar)

instance WriteForeign Calendar where
  writeImpl (Calendar r) = writeImpl { calendar: encodeCalendar r }


instance Random Calendar where
  random = η $ Calendar { calendar: Map.empty }

data CalendarKey = CalendarKey

derive instance Generic CalendarKey _
derive instance Eq CalendarKey
derive instance Ord CalendarKey

instance ToAliasedPrimary CalendarKey where
  toAliasedPrimary _ = { primary: "calendar", aliases: [] }

-- Find

type GET_NEWSLETTER_CALENDAR_CALENDAR_PROJECTION_READ_FIND fx = (getNewsletterCalendarCalendarProjectionReadFind :: Find Calendar | fx)
type GET_NEWSLETTER_CALENDAR_CALENDAR_PROJECTION_READ fx =
  GET_NEWSLETTER_CALENDAR_CALENDAR_PROJECTION_READ_FIND
    + GET_NEWSLETTER_CALENDAR_PROJECTION_READ_SYNC_PROJECT
    + fx

findCalendar :: ∀ fx. Run (GET_NEWSLETTER_CALENDAR_CALENDAR_PROJECTION_READ + fx) (Maybe Calendar)
findCalendar = findOneByKey CalendarKey

-- Play

play :: ∀ fx. LoadedEvent -> Run (GET_NEWSLETTER_CALENDAR_PROJECTION_WRITE_OPS fx) Ɩ
play { event } = case event of
  NewsletterScheduled payload -> onNewsletterScheduled payload
  AuthorReferenced _ -> ηι
  AuthorDereferenced _ -> ηι
  BookReferenced _ -> ηι
  BookDereferenced _ -> ηι
  MagazineIssueReferenced _ -> ηι
  MagazineIssueDereferenced _ -> ηι
  EditorReferenced _ -> ηι
  EditorDereferenced _ -> ηι
  UserEmailChanged _ -> ηι
  UserRegistered _ -> ηι
  UserUnregistered _ -> ηι
  ArticleDiscarded _ -> ηι
  ArticleFeaturedOnFrontPage _ -> ηι
  ArticleWritten _ -> ηι
  ArticleQuoted _ -> ηι
  NewsTopicAdded _ -> ηι
  NewsTopicRemoved _ -> ηι
  ArticleAddedToNewsRelatedWhitelist _ -> ηι
  ArticleRemovedFromNewsRelatedWhitelist _ -> ηι
  ArticleAddedToNewsRelatedBlacklist _ -> ηι
  ArticleRemovedFromNewsRelatedBlacklist _ -> ηι
  ArticleRead _ -> ηι
  MagazineCustomSectionAdded _ -> ηι
  UserDonated _ -> ηι

onNewsletterScheduled :: ∀ fx. NewsletterScheduled.Payload -> Run (GET_NEWSLETTER_CALENDAR_PROJECTION_WRITE_OPS fx) Ɩ
onNewsletterScheduled { id, scheduledFor } = do
  let 
    dt = Data.DateTime.Instant.toDateTime (Safe.Coerce.coerce scheduledFor :: Data.DateTime.Instant.Instant)
    year = Year $ Data.Date.year (Data.DateTime.date dt)
    month = Month $ Data.Date.month (Data.DateTime.date dt)

  mCalendar <- get CalendarKey

  case mCalendar of
    Just (Calendar r) -> do
      let
        item = { id, scheduledFor }
        upsertMonth = Map.alter (\n -> Just (Array.nub (Array.snoc (fromMaybe [] n) item))) month
        upsertYear = Map.alter (\m -> Just (upsertMonth (fromMaybe Map.empty m))) year

      put $ Calendar r { calendar = upsertYear r.calendar }
      
    Nothing -> do
      let item = { id, scheduledFor }
      add $ Calendar { calendar: Map.singleton year (Map.singleton month [item]) }
