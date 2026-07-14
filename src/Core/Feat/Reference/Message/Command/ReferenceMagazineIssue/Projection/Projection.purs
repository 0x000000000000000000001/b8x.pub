module Core.Feat.Reference.Message.Command.ReferenceMagazineIssue.Projection.Projection where

import Proem hiding (add)

import Core.Event.Event (Event(..), LoadedEvent)
import Core.Event.MagazineIssueReferenced.Payload as MagazineIssueReferenced
import Core.Mod.MagazineIssue.Id.Id (MagazineIssueId)
import Core.Mod.MagazineIssue.Slug.Slug (Slug)
import Core.Mod.Projection.Finder.Filter (StrictlyEquals(..))
import Core.Mod.Projection.Finder.Finder (Find, findOneBy)
import Core.Mod.Projection.Pair (class IsPair, class ToAliasedPrimary)
import Core.Mod.Projection.Projection (class IsProjection, ProjectionWriteOps, add, coerce)
import Core.Mod.Projection.SearchIndex (RawIndexOnly, rawIndexOnly)
import Core.Mod.Projection.SyncProject (SyncProject)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Generic.Rep (class Generic)
import Data.Maybe (Maybe)
import Data.Newtype (class Newtype)
import Run (Run)
import Type.Row (type (+))
import Util.Type.String.ToString (toString)

data ReferenceMagazineIssueProjection

instance
  IsProjection
    ReferenceMagazineIssueProjection
    "referenceMagazineIssue"
    "referenceMagazineIssueProjectionWriteOps"
    (REFERENCE_MAGAZINE_ISSUE_PROJECTION_WRITE_OPS ())
    "referenceMagazineIssueProjectionReadSyncProject"
    { referenceMagazineIssue :: MagazineIssue }
    { referenceMagazineIssue :: MagazineIssueIndexNeeds }
    { referenceMagazineIssue :: Record () }
  where
  indexNeeds =
    { referenceMagazineIssue:
        { id: rawIndexOnly
        , slug: rawIndexOnly
        }
    }

  play = coerce @(REFERENCE_MAGAZINE_ISSUE_PROJECTION_WRITE_OPS ()) play

type REFERENCE_MAGAZINE_ISSUE_PROJECTION_WRITE_OPS fx = (referenceMagazineIssueProjectionWriteOps :: ProjectionWriteOps | fx)
type REFERENCE_MAGAZINE_ISSUE_PROJECTION_READ_SYNC_PROJECT fx = (referenceMagazineIssueProjectionReadSyncProject :: SyncProject | fx)

-- Model

instance
  IsPair
    MagazineIssueKey
    MagazineIssue
    MagazineIssueRecord
    MagazineIssueIndexNeeds
    ()
    "referenceMagazineIssue"
    "referenceMagazineIssueMagazineIssues"
    "referenceMagazineIssueProjectionReadFind"
    ReferenceMagazineIssueProjection
  where
  toKey (MagazineIssue { id }) = MagazineIssueKey id
  single = false

newtype MagazineIssue = MagazineIssue MagazineIssueRecord

type MagazineIssueRecord =
  { id :: MagazineIssueId
  , slug :: Slug
  }

type MagazineIssueIndexNeeds =
  { id :: RawIndexOnly MagazineIssueId
  , slug :: RawIndexOnly Slug
  }

derive instance Newtype MagazineIssue _
derive instance Generic MagazineIssue _
derive instance Eq MagazineIssue
derive instance Ord MagazineIssue
derive newtype instance ReadForeign MagazineIssue
derive newtype instance WriteForeign MagazineIssue
derive newtype instance Show MagazineIssue

newtype MagazineIssueKey = MagazineIssueKey MagazineIssueId

derive instance Newtype MagazineIssueKey _
instance ToAliasedPrimary MagazineIssueKey where
  toAliasedPrimary (MagazineIssueKey id) = { primary: toString id, aliases: [] }
derive newtype instance Eq MagazineIssueKey
derive newtype instance Ord MagazineIssueKey

-- Find

type REFERENCE_MAGAZINE_ISSUE_PROJECTION_READ_FIND fx = (referenceMagazineIssueProjectionReadFind :: Find MagazineIssue | fx)
type REFERENCE_MAGAZINE_ISSUE_PROJECTION_READ fx =
  REFERENCE_MAGAZINE_ISSUE_PROJECTION_READ_FIND
    + REFERENCE_MAGAZINE_ISSUE_PROJECTION_READ_SYNC_PROJECT
    + fx

findMagazineIssueBySlug
  :: ∀ fx
   . Slug
  -> Run (REFERENCE_MAGAZINE_ISSUE_PROJECTION_READ + fx) (Maybe MagazineIssue)
findMagazineIssueBySlug slug = findOneBy @MagazineIssue @"slug" StrictlyEquals slug

-- Play

play :: ∀ fx. LoadedEvent -> Run (REFERENCE_MAGAZINE_ISSUE_PROJECTION_WRITE_OPS fx) Ɩ
play { event } = case event of
  MagazineIssueReferenced payload -> onMagazineIssueReferenced payload
  AuthorReferenced _ -> ηι
  AuthorDereferenced _ -> ηι
  BookReferenced _ -> ηι
  BookDereferenced _ -> ηι
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
  NewsletterScheduled _ -> ηι
  MagazineCustomSectionAdded _ -> ηι
  UserDonated _ -> ηι

onMagazineIssueReferenced :: ∀ fx. MagazineIssueReferenced.Payload -> Run (REFERENCE_MAGAZINE_ISSUE_PROJECTION_WRITE_OPS fx) Ɩ
onMagazineIssueReferenced { id, slug } = add $ MagazineIssue { id, slug }

