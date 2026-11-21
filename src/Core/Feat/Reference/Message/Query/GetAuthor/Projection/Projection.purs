module Core.Feat.Reference.Message.Query.GetAuthor.Projection.Projection where

import Proem hiding (add)

import Core.Event.AuthorBiographyCorrected.Payload as AuthorBiographyCorrected
import Core.Event.AuthorDereferenced.Payload as AuthorDereferenced
import Core.Event.AuthorReferenced.Payload as AuthorReferenced
import Core.Event.Event (Event(..), LoadedEvent)
import Core.Mod.Author.Biography.Biography (Biography)
import Core.Mod.Author.Id.Id (AuthorId)
import Core.Mod.Author.LegacyIds.LegacyIds (LegacyIds)
import Core.Mod.Author.Name.Name (Name)
import Core.Mod.Image.Image (Image)
import Core.Mod.Projection.Finder.Finder (Find, findOneByKey)
import Core.Mod.Projection.Pair (class IsPair, class ToPrimary, class ToAliases)
import Core.Mod.Projection.Projection (class IsProjection, ProjectionWriteOps, add, delete, coerce, patch)
import Core.Mod.Projection.SyncProject (SyncProject)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Generic.Rep (class Generic)
import Data.Maybe (Maybe)
import Data.Newtype (class Newtype)
import Run (Run)
import Type.Row (type (+))
import Util.Type.String.ToString (toString)

data GetAuthorProjection

instance
  IsProjection
    GetAuthorProjection
    "getAuthor"
    "getAuthorProjectionWriteOps"
    (GET_AUTHOR_PROJECTION_WRITE_OPS ())
    "getAuthorProjectionReadSyncProject"
    { author :: Author }
    { author :: AuthorIndexNeeds }
    { author :: Record () }
  where
  indexNeeds =
    { author: {}
    }

  play = coerce @(GET_AUTHOR_PROJECTION_WRITE_OPS ()) play

type GET_AUTHOR_PROJECTION_WRITE_OPS fx = (getAuthorProjectionWriteOps :: ProjectionWriteOps | fx)
type GET_AUTHOR_PROJECTION_READ_SYNC_PROJECT fx = (getAuthorProjectionReadSyncProject :: SyncProject | fx)

-- Model

instance
  IsPair
    AuthorKey
    Author
    AuthorRecord
    AuthorIndexNeeds
    ()
    "author"
    "authors"
    "getAuthorProjectionReadFind"
    GetAuthorProjection
  where
  toKey (Author { id }) = AuthorKey id
  single = false

newtype Author = Author AuthorRecord

instance ToAliases Author where
  toAliases _ = []

type AuthorRecord =
  { id :: AuthorId
  , name :: Name
  , biography :: Biography
  , legacyIds :: LegacyIds
  , portrait :: Maybe Image
  }

type AuthorIndexNeeds = {}

derive instance Newtype Author _
derive instance Generic Author _
derive instance Eq Author
derive instance Ord Author
derive newtype instance ReadForeign Author
derive newtype instance WriteForeign Author
derive newtype instance Show Author

newtype AuthorKey = AuthorKey AuthorId

derive instance Newtype AuthorKey _
instance ToPrimary AuthorKey where
  toPrimary (AuthorKey id) = toString id

derive newtype instance Eq AuthorKey
derive newtype instance Ord AuthorKey

-- Find

type GET_AUTHOR_PROJECTION_READ_FIND fx = (getAuthorProjectionReadFind :: Find Author | fx)
type GET_AUTHOR_PROJECTION_READ fx =
  GET_AUTHOR_PROJECTION_READ_FIND
    + GET_AUTHOR_PROJECTION_READ_SYNC_PROJECT
    + fx

findAuthorById
  :: ∀ fx
   . AuthorId
  -> Run (GET_AUTHOR_PROJECTION_READ + fx) (Maybe Author)
findAuthorById id = findOneByKey (AuthorKey id)

-- Play

play :: ∀ fx. LoadedEvent -> Run (GET_AUTHOR_PROJECTION_WRITE_OPS fx) Ɩ
play { event } = case event of
  AuthorReferenced payload -> onAuthorReferenced payload
  AuthorDereferenced payload -> onAuthorDereferenced payload
  BookReferenced _ -> ηι
  BookDereferenced _ -> ηι
  BookEditorCorrected _ -> ηι
  BookCoverCorrected _ -> ηι
  ArticleTitleCorrected _ -> ηι
  ArticleContentCorrected _ -> ηι
  ArticleLeadCorrected _ -> ηι
  AuthorBiographyCorrected payload -> onAuthorBiographyCorrected payload
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

onAuthorReferenced :: ∀ fx. AuthorReferenced.Payload -> Run (GET_AUTHOR_PROJECTION_WRITE_OPS fx) Ɩ
onAuthorReferenced { id, name, biography, legacyIds, portrait } = add $ Author { id, name, biography, legacyIds, portrait }

onAuthorDereferenced :: ∀ fx. AuthorDereferenced.Payload -> Run (GET_AUTHOR_PROJECTION_WRITE_OPS fx) Ɩ
onAuthorDereferenced { author } = delete $ AuthorKey author

onAuthorBiographyCorrected :: ∀ fx. AuthorBiographyCorrected.Payload -> Run (GET_AUTHOR_PROJECTION_WRITE_OPS fx) Ɩ
onAuthorBiographyCorrected { author, biography } = patch (AuthorKey author) \(Author a) -> Author (a { biography = biography })
