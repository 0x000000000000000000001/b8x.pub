module Core.Feat.Reference.Message.Query.VerifyEditorUniqueness.Projection.Projection where

import Proem hiding (add)

import Core.Event.EditorDereferenced.Payload as EditorDereferenced
import Core.Event.EditorReferenced.Payload as EditorReferenced
import Core.Event.Event (Event(..), LoadedEvent)
import Core.Mod.Projection.Finder.Expectation.Expectation (Expectation(..))
import Core.Mod.Editor.Id.Id (EditorId)
import Core.Mod.Editor.Name.Name (Name)
import Core.Mod.Projection.Finder.Filter (Matches(..), noLimit)
import Core.Mod.Projection.Finder.Finder (Find, findManyBy)
import Core.Mod.Projection.Pair (class IsPair, class ToAliasedPrimary)
import Core.Mod.Projection.Projection (class IsProjection, ProjectionWriteOps, add, delete, noAfter, coerce)
import Core.Mod.Projection.SearchIndex (EveryTextIndexesWithWeightA, RawIndexOnly, everyTextIndexesWithWeightA, rawIndexOnly)
import Core.Mod.Projection.SyncProject (SyncProject)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Generic.Rep (class Generic)
import Data.Newtype (class Newtype)
import Run (Run)
import Type.Row (type (+))
import Util.Type.String.ToString (toString)

data VerifyEditorUniquenessProjection

instance
  IsProjection
    VerifyEditorUniquenessProjection
    "verifyEditorUniqueness"
    "verifyEditorUniquenessProjectionWriteOps"
    (VERIFY_EDITOR_UNIQUENESS_PROJECTION_WRITE_OPS ())
    "verifyEditorUniquenessProjectionReadSyncProject"
    { verifyEditorUniqueness :: Editor }
    { verifyEditorUniqueness :: EditorIndexNeeds }
    { verifyEditorUniqueness :: Record () }
  where
  indexNeeds =
    { verifyEditorUniqueness:
        { id: rawIndexOnly
        , name: everyTextIndexesWithWeightA
        }
    }

  play = coerce @(VERIFY_EDITOR_UNIQUENESS_PROJECTION_WRITE_OPS ()) play

type VERIFY_EDITOR_UNIQUENESS_PROJECTION_WRITE_OPS fx = (verifyEditorUniquenessProjectionWriteOps :: ProjectionWriteOps | fx)
type VERIFY_EDITOR_UNIQUENESS_PROJECTION_READ_SYNC_PROJECT fx = (verifyEditorUniquenessProjectionReadSyncProject :: SyncProject | fx)

-- Model

instance
  IsPair
    EditorKey
    Editor
    EditorRecord
    EditorIndexNeeds
    ()
    "verifyEditorUniqueness"
    "verifyEditorUniquenessEditors"
    "verifyEditorUniquenessProjectionReadFind"
    VerifyEditorUniquenessProjection
  where
  toKey (Editor { id }) = EditorKey id
  single = false

newtype Editor = Editor EditorRecord

type EditorRecord =
  { id :: EditorId
  , name :: Name
  }

type EditorIndexNeeds =
  { id :: RawIndexOnly EditorId
  , name :: EveryTextIndexesWithWeightA Name
  }

derive instance Newtype Editor _
derive instance Generic Editor _
derive instance Eq Editor
derive instance Ord Editor
derive newtype instance ReadForeign Editor
derive newtype instance WriteForeign Editor
derive newtype instance Show Editor

newtype EditorKey = EditorKey EditorId

derive instance Newtype EditorKey _
instance ToAliasedPrimary EditorKey where
  toAliasedPrimary (EditorKey id) = { primary: toString id, aliases: [] }
derive newtype instance Eq EditorKey
derive newtype instance Ord EditorKey

-- Find

type VERIFY_EDITOR_UNIQUENESS_PROJECTION_READ_FIND fx = (verifyEditorUniquenessProjectionReadFind :: Find Editor | fx)
type VERIFY_EDITOR_UNIQUENESS_PROJECTION_READ fx =
  VERIFY_EDITOR_UNIQUENESS_PROJECTION_READ_FIND
    + VERIFY_EDITOR_UNIQUENESS_PROJECTION_READ_SYNC_PROJECT
    + fx

findEditorsByName
  :: ∀ fx
   . Name
  -> Run (VERIFY_EDITOR_UNIQUENESS_PROJECTION_READ + fx) (Array Editor)
findEditorsByName name = findManyBy @Editor @"name" (Matches { weight: 1.0, expectation: QuickNothingBetterThanSlowerSomething }) name noLimit noAfter

-- Play

play :: ∀ fx. LoadedEvent -> Run (VERIFY_EDITOR_UNIQUENESS_PROJECTION_WRITE_OPS fx) Ɩ
play { event } = case event of
  EditorReferenced payload -> onEditorReferenced payload
  EditorDereferenced payload -> onEditorDereferenced payload
  AuthorReferenced _ -> ηι
  AuthorDereferenced _ -> ηι
  BookReferenced _ -> ηι
  BookDereferenced _ -> ηι
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

onEditorReferenced :: ∀ fx. EditorReferenced.Payload -> Run (VERIFY_EDITOR_UNIQUENESS_PROJECTION_WRITE_OPS fx) Ɩ
onEditorReferenced { id, name } = add $ Editor { id, name }

onEditorDereferenced :: ∀ fx. EditorDereferenced.Payload -> Run (VERIFY_EDITOR_UNIQUENESS_PROJECTION_WRITE_OPS fx) Ɩ
onEditorDereferenced { editor } = delete $ EditorKey editor
