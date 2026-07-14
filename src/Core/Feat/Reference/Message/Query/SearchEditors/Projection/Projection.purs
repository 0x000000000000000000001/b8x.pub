module Core.Feat.Reference.Message.Query.SearchEditors.Projection.Projection where

import Yoga.JSON.Generics (genericWriteForeignTaggedSum, genericReadForeignTaggedSum)
import Yoga.JSON.Generics.TaggedSumRep (defaultOptions)
import Proem hiding (add)
import Control.Monad.Except as Control.Monad.Except

import Core.Event.EditorDereferenced.Payload as EditorDereferenced
import Core.Event.EditorReferenced.Payload as EditorReferenced
import Core.Event.Event (Event(..), LoadedEvent)
import Core.Exception.Exception (inj)
import Core.Mod.Editor.Id.Id (EditorId)
import Core.Mod.Editor.Name.Name (Name)
import Core.Feat.Reference.Message.Query.SearchEditors.Exception.InvalidEditorFilter (InvalidEditorFilter(..), InvalidEditorFilterRow)
import Core.Mod.Projection.Finder.Filter (class IsFilter, Contains(..), EqualsUpToNormalization(..), StrictlyEquals(..), by, compile)
import Core.Mod.Projection.Finder.Filter as Base
import Core.Mod.Projection.Finder.Finder (Find, FindOpt, Page, findMany_)
import Core.Mod.Projection.Pair (class IsPair, class ToAliasedPrimary, persistenceKeyFromKey)
import Core.Mod.Projection.Projection (class IsProjection, ProjectionWriteOps, add, coerce, delete)
import Core.Mod.Projection.SearchIndex (EveryTextIndexesWithWeightA, InvertedIndexOnly, RawIndexOnly, everyTextIndexesWithWeightA, invertedIndexOnly, rawIndexOnly)
import Core.Mod.Projection.SyncProject (SyncProject)
import Core.Util.Validation (class IsRefinedType)
import Yoga.JSON (class ReadForeign, class WriteForeign, readImpl)
import Data.Either (Either(..))
import Data.Generic.Rep (class Generic)
import Data.Newtype (class Newtype)
import Data.Show.Generic (genericShow)
import Run (Run)
import Type.Row (type (+))
import Util.Type.Random (class Random, random)
import Util.Type.String.ToString (toString)

data SearchEditorsProjection

instance
  IsProjection
    SearchEditorsProjection
    "searchEditors"
    "searchEditorsProjectionWriteOps"
    (SEARCH_EDITORS_PROJECTION_WRITE_OPS ())
    "searchEditorsProjectionReadSyncProject"
    { searchEditors :: Editor }
    { searchEditors :: EditorIndexNeeds }
    { searchEditors :: Record () }
  where
  indexNeeds =
    { searchEditors:
        { id: rawIndexOnly
        , name: everyTextIndexesWithWeightA
        , legacyBookIds: invertedIndexOnly
        }
    }

  play = coerce @(SEARCH_EDITORS_PROJECTION_WRITE_OPS ()) play

type SEARCH_EDITORS_PROJECTION_WRITE_OPS fx = (searchEditorsProjectionWriteOps :: ProjectionWriteOps | fx)
type SEARCH_EDITORS_PROJECTION_READ_SYNC_PROJECT fx = (searchEditorsProjectionReadSyncProject :: SyncProject | fx)

-- Model 

instance IsPair EditorKey Editor EditorRecord EditorIndexNeeds () "searchEditors" "searchEditorsEditors" "searchEditorsProjectionReadFind" SearchEditorsProjection where
  toKey (Editor { id }) = EditorKey id

  single = false

newtype Editor = Editor EditorRecord

type EditorRecord =
  { id :: EditorId
  , name :: Name
  , legacyBookIds :: Array Int
  }

type EditorIndexNeeds =
  { id :: RawIndexOnly EditorId
  , name :: EveryTextIndexesWithWeightA Name
  , legacyBookIds :: InvertedIndexOnly (Array Int)
  }

derive instance Newtype Editor _
derive instance Generic Editor _
derive instance Eq Editor
derive instance Ord Editor
derive newtype instance ReadForeign Editor
derive newtype instance WriteForeign Editor
derive newtype instance Random Editor
derive newtype instance Show Editor

newtype EditorKey = EditorKey EditorId

derive instance Newtype EditorKey _
instance ToAliasedPrimary EditorKey where
  toAliasedPrimary (EditorKey id) = { primary: toString id, aliases: [] }
derive newtype instance Eq EditorKey
derive newtype instance Ord EditorKey

-- Filter

data EditorFilter
  = EditorHasId EditorId
  | EditorHasExactName Name
  | EditorHasLegacyBookId Int
  | EditorAnd { left :: EditorFilter, right :: EditorFilter }
  | EditorOr { left :: EditorFilter, right :: EditorFilter }
  | EditorNot EditorFilter
  | EditorTrue
  | EditorFalse

derive instance Eq EditorFilter
derive instance Ord EditorFilter
derive instance Generic EditorFilter _

instance Show EditorFilter where
  show filter = genericShow filter

instance WriteForeign EditorFilter where
  writeImpl filter = (genericWriteForeignTaggedSum defaultOptions) filter

instance ReadForeign EditorFilter where
  readImpl json = (genericReadForeignTaggedSum defaultOptions) json

instance HeytingAlgebra EditorFilter where
  ff = EditorFalse
  tt = EditorTrue
  not = EditorNot
  implies a b = (EditorNot a) || b
  conj left right = EditorAnd { left, right }
  disj left right = EditorOr { left, right }

instance IsFilter EditorFilter Editor where
  compile _ (EditorHasId id) = by @"id" StrictlyEquals id
  compile _ (EditorHasExactName name) = by @"name" EqualsUpToNormalization name
  compile _ (EditorHasLegacyBookId legacyBookId) = by @"legacyBookIds" Contains [ legacyBookId ]

  compile e (EditorAnd { left: f1, right: f2 }) =
    (compile e f1)
      && (compile e f2)

  compile e (EditorOr { left: f1, right: f2 }) =
    (compile e f1)
      || (compile e f2)

  compile e (EditorNot f) = not (compile e f)

  compile _ EditorTrue = Base.True
  compile _ EditorFalse = Base.False

instance IsRefinedType EditorFilter (InvalidEditorFilterRow ()) where
  makeFromJson _ json = case Control.Monad.Except.runExcept (readImpl json) of
    Left _ -> Left $ inj InvalidEditorFilter
    Right filter -> η filter

instance Random EditorFilter where
  random = EditorHasId <$> random

-- Find

type SEARCH_EDITORS_PROJECTION_READ_FIND fx = (searchEditorsProjectionReadFind :: Find Editor | fx)
type SEARCH_EDITORS_PROJECTION_READ fx =
  SEARCH_EDITORS_PROJECTION_READ_FIND
    + SEARCH_EDITORS_PROJECTION_READ_SYNC_PROJECT
    + fx

findEditors
  :: ∀ fx
   . FindOpt EditorFilter EditorId Editor
  -> Run (SEARCH_EDITORS_PROJECTION_READ + fx) (Page Editor)
findEditors opt = findMany_ opt { after = opt.after <#> EditorKey ▷ persistenceKeyFromKey }

-- Play 

play :: ∀ fx. LoadedEvent -> Run (SEARCH_EDITORS_PROJECTION_WRITE_OPS fx) Ɩ
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

---- Listeners

onEditorReferenced :: ∀ fx. EditorReferenced.Payload -> Run (SEARCH_EDITORS_PROJECTION_WRITE_OPS fx) Ɩ
onEditorReferenced { id, name, legacyBookIds } = add $ Editor { id, name, legacyBookIds }

onEditorDereferenced :: ∀ fx. EditorDereferenced.Payload -> Run (SEARCH_EDITORS_PROJECTION_WRITE_OPS fx) Ɩ
onEditorDereferenced { editor } = delete $ EditorKey editor


