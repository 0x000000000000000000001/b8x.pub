module Core.Feat.Reference.Message.Query.VerifyAuthorUniqueness.Projection.Projection where

import Proem hiding (add)

import Core.Event.AuthorDereferenced.Payload as AuthorDereferenced
import Core.Event.AuthorReferenced.Payload as AuthorReferenced
import Core.Event.Event (Event(..), LoadedEvent)
import Core.Mod.Projection.Finder.Expectation.Expectation (Expectation(..))
import Core.Mod.Author.Id.Id (AuthorId)
import Core.Mod.Author.Name.Name (Name)
import Core.Mod.Author.LegacyIds.LegacyIds (LegacyIds)
import Core.Mod.Projection.Finder.Filter (Matches(..), noLimit)
import Core.Mod.Projection.Finder.Finder (Find, findManyBy)
import Core.Mod.Projection.Pair (class IsPair, class ToAliasedPrimary)
import Core.Mod.Projection.Projection (class IsProjection, ProjectionWriteOps, add, delete, coerce, noAfter)
import Core.Mod.Projection.SearchIndex (EveryTextIndexesWithWeightA, InvertedIndexOnly, RawIndexOnly, everyTextIndexesWithWeightA, invertedIndexOnly, rawIndexOnly)
import Core.Mod.Projection.SyncProject (SyncProject)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Generic.Rep (class Generic)
import Data.Newtype (class Newtype)
import Run (Run)
import Type.Row (type (+))
import Util.Type.String.ToString (toString)

data VerifyAuthorUniquenessProjection

instance
  IsProjection
    VerifyAuthorUniquenessProjection
    "verifyAuthorUniqueness"
    "verifyAuthorUniquenessProjectionWriteOps"
    (VERIFY_AUTHOR_UNIQUENESS_PROJECTION_WRITE_OPS ())
    "verifyAuthorUniquenessProjectionReadSyncProject"
    { verifyAuthorUniqueness :: Author }
    { verifyAuthorUniqueness :: AuthorIndexNeeds }
    { verifyAuthorUniqueness :: Record () }
  where
  indexNeeds =
    { verifyAuthorUniqueness:
        { id: rawIndexOnly
        , name: everyTextIndexesWithWeightA
        , legacyIds: invertedIndexOnly
        }
    }

  play = coerce @(VERIFY_AUTHOR_UNIQUENESS_PROJECTION_WRITE_OPS ()) play

type VERIFY_AUTHOR_UNIQUENESS_PROJECTION_WRITE_OPS fx = (verifyAuthorUniquenessProjectionWriteOps :: ProjectionWriteOps | fx)
type VERIFY_AUTHOR_UNIQUENESS_PROJECTION_READ_SYNC_PROJECT fx = (verifyAuthorUniquenessProjectionReadSyncProject :: SyncProject | fx)

-- Model

instance
  IsPair
    AuthorKey
    Author
    AuthorRecord
    AuthorIndexNeeds
    ()
    "verifyAuthorUniqueness"
    "verifyAuthorUniquenessAuthors"
    "verifyAuthorUniquenessProjectionReadFind"
    VerifyAuthorUniquenessProjection
  where
  toKey (Author { id }) = AuthorKey id
  single = false

newtype Author = Author AuthorRecord

type AuthorRecord =
  { id :: AuthorId
  , name :: Name
  , legacyIds :: LegacyIds
  }

type AuthorIndexNeeds =
  { id :: RawIndexOnly AuthorId
  , name :: EveryTextIndexesWithWeightA Name
  , legacyIds :: InvertedIndexOnly LegacyIds
  }

derive instance Newtype Author _
derive instance Generic Author _
derive instance Eq Author
derive instance Ord Author
derive newtype instance ReadForeign Author
derive newtype instance WriteForeign Author
derive newtype instance Show Author

newtype AuthorKey = AuthorKey AuthorId

derive instance Newtype AuthorKey _
instance ToAliasedPrimary AuthorKey where
  toAliasedPrimary (AuthorKey id) = { primary: toString id, aliases: [] }
derive newtype instance Eq AuthorKey
derive newtype instance Ord AuthorKey

-- Find

type VERIFY_AUTHOR_UNIQUENESS_PROJECTION_READ_FIND fx = (verifyAuthorUniquenessProjectionReadFind :: Find Author | fx)
type VERIFY_AUTHOR_UNIQUENESS_PROJECTION_READ fx =
  VERIFY_AUTHOR_UNIQUENESS_PROJECTION_READ_FIND
    + VERIFY_AUTHOR_UNIQUENESS_PROJECTION_READ_SYNC_PROJECT
    + fx

findAuthorsByName
  :: ∀ fx
   . Name
  -> Run (VERIFY_AUTHOR_UNIQUENESS_PROJECTION_READ + fx) (Array Author)
findAuthorsByName name = findManyBy @Author @"name" (Matches { weight: 1.0, expectation: QuickNothingBetterThanSlowerSomething }) name noLimit noAfter

-- Play

play :: ∀ fx. LoadedEvent -> Run (VERIFY_AUTHOR_UNIQUENESS_PROJECTION_WRITE_OPS fx) Ɩ
play { event } = case event of
  AuthorReferenced payload -> onAuthorReferenced payload
  AuthorDereferenced payload -> onAuthorDereferenced payload
  BookReferenced _ -> ηι
  BookDereferenced _ -> ηι
  EditorReferenced _ -> ηι
  EditorDereferenced _ -> ηι
  MagazineIssueReferenced _ -> ηι
  MagazineIssueDereferenced _ -> ηι
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

onAuthorReferenced :: ∀ fx. AuthorReferenced.Payload -> Run (VERIFY_AUTHOR_UNIQUENESS_PROJECTION_WRITE_OPS fx) Ɩ
onAuthorReferenced { id, name, legacyIds } = add $ Author { id, name, legacyIds }

onAuthorDereferenced :: ∀ fx. AuthorDereferenced.Payload -> Run (VERIFY_AUTHOR_UNIQUENESS_PROJECTION_WRITE_OPS fx) Ɩ
onAuthorDereferenced { author } = delete $ AuthorKey author
