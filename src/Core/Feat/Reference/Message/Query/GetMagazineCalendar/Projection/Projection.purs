module Core.Feat.Reference.Message.Query.GetMagazineCalendar.Projection.Projection where

import Proem hiding (add)

import Data.Tuple (Tuple)
import Control.Monad.Except as Control.Monad.Except
import Core.Event.Event (Event(..), LoadedEvent)
import Core.Event.MagazineIssueReferenced.Payload as MagazineIssueReferenced
import Core.Event.MagazineIssueDereferenced.Payload as MagazineIssueDereferenced
import Core.Mod.MagazineIssue.Id.Id (MagazineIssueId)
import Core.Mod.MagazineIssue.Number.Number (IssueNumber)
import Core.Mod.MagazineIssue.Slug.Slug (Slug)
import Core.Mod.Image.Image (Image)
import Core.Mod.MagazineIssue.ReleasedAt.ReleasedAt (ReleasedAt(..))
import Core.Mod.Time.Year (Year)
import Core.Mod.Projection.Finder.Finder (Find, findOneByKey)
import Core.Mod.Projection.Pair (class IsPair, class ToAliasedPrimary)
import Core.Mod.Projection.Projection (class IsProjection, ProjectionWriteOps, add, coerce, get, put)
import Core.Mod.Projection.SyncProject (SyncProject)
import Yoga.JSON (class ReadForeign, class WriteForeign, readImpl, writeImpl)
import Data.Array as Array
import Data.Generic.Rep (class Generic)
import Data.Map (Map)
import Data.Map as Map
import Data.Maybe (Maybe(..), fromMaybe)
import Data.Newtype (class Newtype)
import Run (Run)
import Type.Row (type (+))
import Util.Type.Random (class Random)
import Util.Type.String.ToString (toString)

data GetMagazineCalendarProjection

instance
  IsProjection
    GetMagazineCalendarProjection
    "getMagazineCalendar"
    "getMagazineCalendarProjectionWriteOps"
    (GET_MAGAZINE_CALENDAR_PROJECTION_WRITE_OPS ())
    "getMagazineCalendarProjectionReadSyncProject"
    { calendar :: Calendar }
    { calendar :: CalendarIndexNeeds }
    { calendar :: {} }
  where
  indexNeeds = { calendar: {} }

  play = coerce @(GET_MAGAZINE_CALENDAR_PROJECTION_WRITE_OPS ()) play

type GET_MAGAZINE_CALENDAR_PROJECTION_WRITE_OPS fx = (getMagazineCalendarProjectionWriteOps :: ProjectionWriteOps | fx)
type GET_MAGAZINE_CALENDAR_PROJECTION_READ_SYNC_PROJECT fx = (getMagazineCalendarProjectionReadSyncProject :: SyncProject | fx)
type GET_MAGAZINE_CALENDAR_PROJECTION_READ_FIND fx = GET_MAGAZINE_CALENDAR_CALENDAR_PROJECTION_READ_FIND
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
    "getMagazineCalendarCalendarProjectionReadFind"
    GetMagazineCalendarProjection
  where
  toKey _ = CalendarKey

  single = true

newtype Calendar = Calendar CalendarRecord

type Item =
  { id :: MagazineIssueId
  , name :: String
  , number :: IssueNumber
  , slug :: Slug
  , cover :: Maybe Image
  , releasedAt :: Maybe ReleasedAt
  }

type CalendarRecord =
  { calendar :: Map Year (Array Item)
  }

type CalendarIndexNeeds = {}

derive instance Newtype Calendar _
derive instance Generic Calendar _
derive instance Eq Calendar
derive instance Ord Calendar

instance ReadForeign Calendar where
  readImpl f = do
    arr <- readImpl f :: Control.Monad.Except.ExceptT _ _ (Array (Tuple Year (Array { cover :: Maybe Image, id :: MagazineIssueId, name :: String, number :: Int, releasedAt :: Maybe ReleasedAt, slug :: Slug })))
    pure (Calendar { calendar: Map.fromFoldable arr })

encodeCalendar :: CalendarRecord -> Array (Tuple Year (Array { cover :: Maybe Image, id :: MagazineIssueId, name :: String, number :: Int, releasedAt :: Maybe ReleasedAt, slug :: Slug }))
encodeCalendar r = Map.toUnfoldable r.calendar

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

type GET_MAGAZINE_CALENDAR_CALENDAR_PROJECTION_READ_FIND fx = (getMagazineCalendarCalendarProjectionReadFind :: Find Calendar | fx)
type GET_MAGAZINE_CALENDAR_CALENDAR_PROJECTION_READ fx =
  GET_MAGAZINE_CALENDAR_CALENDAR_PROJECTION_READ_FIND
    + GET_MAGAZINE_CALENDAR_PROJECTION_READ_SYNC_PROJECT
    + fx

findCalendar :: ∀ fx. Run (GET_MAGAZINE_CALENDAR_CALENDAR_PROJECTION_READ + fx) (Maybe Calendar)
findCalendar = findOneByKey CalendarKey

-- Play

play :: ∀ fx. LoadedEvent -> Run (GET_MAGAZINE_CALENDAR_PROJECTION_WRITE_OPS fx) Ɩ
play { event } = case event of
  MagazineIssueReferenced payload -> onMagazineIssueReferenced payload
  MagazineIssueDereferenced payload -> onMagazineIssueDereferenced payload
  AuthorReferenced _ -> ηι
  AuthorDereferenced _ -> ηι
  BookReferenced _ -> ηι
  BookDereferenced _ -> ηι
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
  NewsletterScheduled _ -> ηι
  MagazineCustomSectionAdded _ -> ηι
  UserDonated _ -> ηι

onMagazineIssueReferenced :: ∀ fx. MagazineIssueReferenced.Payload -> Run (GET_MAGAZINE_CALENDAR_PROJECTION_WRITE_OPS fx) Ɩ
onMagazineIssueReferenced { id, name, number, slug, cover, releasedAt } = do
  case releasedAt of
    Just rAt -> do
      let
        year = case rAt of
          Single date -> date.year
          Span s -> s.start.year

      mCalendar <- get CalendarKey

      case mCalendar of
        Just (Calendar r) -> do
          let
            item = { id, name: toString name, number, slug, cover, releasedAt }
            upsertYear = Map.alter (\n -> Just (Array.nub (Array.snoc (fromMaybe [] n) item))) year

          put $ Calendar r { calendar = upsertYear r.calendar }

        Nothing -> do
          let item = { id, name: toString name, number, slug, cover, releasedAt }
          add $ Calendar { calendar: Map.singleton year [ item ] }
    Nothing -> ηι

onMagazineIssueDereferenced :: ∀ fx. MagazineIssueDereferenced.Payload -> Run (GET_MAGAZINE_CALENDAR_PROJECTION_WRITE_OPS fx) Ɩ
onMagazineIssueDereferenced { issue } = do
  mCalendar <- get CalendarKey
  case mCalendar of
    Just (Calendar r) -> do
      -- Remove the issue from all years
      let
        newCalendar = map (Array.filter (\item -> item.id /= issue)) r.calendar
        -- Optionally remove empty years:
        cleanCalendar = Map.filter (\arr -> not (Array.null arr)) newCalendar
      put $ Calendar r { calendar = cleanCalendar }
    Nothing -> ηι
