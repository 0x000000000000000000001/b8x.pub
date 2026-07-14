module Core.Feat.Reference.Message.Query.VerifyMagazineIssueUniqueness.Projection.Projection where

import Proem hiding (add)

import Core.Event.Event (Event(..), LoadedEvent)
import Core.Event.MagazineIssueReferenced.Payload as MagazineIssueReferenced
import Core.Mod.MagazineIssue.Id.Id (MagazineIssueId)
import Core.Mod.MagazineIssue.Number.Number (IssueNumber)
import Core.Mod.Projection.Finder.Filter (StrictlyEquals(..), noLimit)
import Core.Mod.Projection.Finder.Finder (Find, findManyBy)
import Core.Mod.Projection.Pair (class IsPair, class ToAliasedPrimary)
import Core.Mod.Projection.Projection (class IsProjection, ProjectionWriteOps, add, coerce, noAfter)
import Core.Mod.Projection.SearchIndex (RawIndexOnly, rawIndexOnly)
import Core.Mod.Projection.SyncProject (SyncProject)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Array (filter)
import Data.Generic.Rep (class Generic)
import Data.Newtype (class Newtype)
import Run (Run)
import Type.Row (type (+))
import Util.Type.String.ToString (toString)

data VerifyMagazineIssueUniquenessProjection

instance
  IsProjection
    VerifyMagazineIssueUniquenessProjection
    "verifyMagazineIssueUniqueness"
    "verifyMagazineIssueUniquenessProjectionWriteOps"
    (VERIFY_MAGAZINE_ISSUE_UNIQUENESS_PROJECTION_WRITE_OPS ())
    "verifyMagazineIssueUniquenessProjectionReadSyncProject"
    { verifyMagazineIssueUniqueness :: MagazineIssue }
    { verifyMagazineIssueUniqueness :: MagazineIssueIndexNeeds }
    { verifyMagazineIssueUniqueness :: Record () }
  where
  indexNeeds =
    { verifyMagazineIssueUniqueness:
        { id: rawIndexOnly
        , number: rawIndexOnly
        }
    }

  play = coerce @(VERIFY_MAGAZINE_ISSUE_UNIQUENESS_PROJECTION_WRITE_OPS ()) play

type VERIFY_MAGAZINE_ISSUE_UNIQUENESS_PROJECTION_WRITE_OPS fx = (verifyMagazineIssueUniquenessProjectionWriteOps :: ProjectionWriteOps | fx)
type VERIFY_MAGAZINE_ISSUE_UNIQUENESS_PROJECTION_READ_SYNC_PROJECT fx = (verifyMagazineIssueUniquenessProjectionReadSyncProject :: SyncProject | fx)

-- Model

instance
  IsPair
    MagazineIssueKey
    MagazineIssue
    MagazineIssueRecord
    MagazineIssueIndexNeeds
    ()
    "verifyMagazineIssueUniqueness"
    "verifyMagazineIssueUniquenessMagazineIssues"
    "verifyMagazineIssueUniquenessProjectionReadFind"
    VerifyMagazineIssueUniquenessProjection
  where
  toKey (MagazineIssue { id }) = MagazineIssueKey id
  single = false

newtype MagazineIssue = MagazineIssue MagazineIssueRecord

type MagazineIssueRecord =
  { id :: MagazineIssueId
  , number :: IssueNumber
  , special :: Boolean
  , complement :: Boolean
  }

type MagazineIssueIndexNeeds =
  { id :: RawIndexOnly MagazineIssueId
  , number :: RawIndexOnly IssueNumber
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

type VERIFY_MAGAZINE_ISSUE_UNIQUENESS_PROJECTION_READ_FIND fx = (verifyMagazineIssueUniquenessProjectionReadFind :: Find MagazineIssue | fx)
type VERIFY_MAGAZINE_ISSUE_UNIQUENESS_PROJECTION_READ fx =
  VERIFY_MAGAZINE_ISSUE_UNIQUENESS_PROJECTION_READ_FIND
    + VERIFY_MAGAZINE_ISSUE_UNIQUENESS_PROJECTION_READ_SYNC_PROJECT
    + fx

findMagazineIssuesByNumberSpecialAndComplement
  :: ∀ fx
   . IssueNumber
  -> Boolean
  -> Boolean
  -> Run (VERIFY_MAGAZINE_ISSUE_UNIQUENESS_PROJECTION_READ + fx) (Array MagazineIssue)
findMagazineIssuesByNumberSpecialAndComplement number special complement = do
  issues <- findManyBy @MagazineIssue @"number" StrictlyEquals number noLimit noAfter
  η $ filter (\(MagazineIssue i) -> i.special == special && i.complement == complement) issues

-- Play

play :: ∀ fx. LoadedEvent -> Run (VERIFY_MAGAZINE_ISSUE_UNIQUENESS_PROJECTION_WRITE_OPS fx) Ɩ
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

onMagazineIssueReferenced :: ∀ fx. MagazineIssueReferenced.Payload -> Run (VERIFY_MAGAZINE_ISSUE_UNIQUENESS_PROJECTION_WRITE_OPS fx) Ɩ
onMagazineIssueReferenced { id, number, special, complement } = add $ MagazineIssue { id, number, special, complement }
