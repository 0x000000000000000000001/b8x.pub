module Core.Feat.Reference.Message.Query.SearchAuthors.Projection.Projection where

import Yoga.JSON.Generics (genericWriteForeignTaggedSum, genericReadForeignTaggedSum)
import Yoga.JSON.Generics.TaggedSumRep (defaultOptions)
import Proem hiding (add)
import Control.Monad.Except as Control.Monad.Except

import Core.Event.AuthorDereferenced.Payload as AuthorDereferenced
import Core.Event.AuthorReferenced.Payload as AuthorReferenced
import Core.Event.Event (Event(..), LoadedEvent)
import Core.Exception.Exception (inj)
import Core.Mod.Author.Biography.Biography (Biography)
import Core.Mod.Author.Id.Id (AuthorId)
import Core.Mod.Author.LegacyIds.LegacyIds (LegacyIds)
import Core.Mod.Author.Name.Name (Name)
import Core.Mod.Image.Image (Image)
import Core.Feat.Reference.Message.Query.SearchAuthors.Projection.Exception.InvalidAuthorFilter (InvalidAuthorFilter(..), InvalidAuthorFilterRow)
import Core.Mod.Projection.Finder.Filter (class IsFilter, Contains(..), EqualsUpToNormalization(..), Matches(..), StrictlyEquals(..), Weight, by, compile)
import Core.Mod.Projection.Finder.Filter as Base
import Core.Mod.Projection.Finder.Finder (Find, FindOpt, Page, findMany_)
import Core.Mod.Projection.Pair (class IsPair, class ToAliasedPrimary, persistenceKeyFromKey)
import Core.Mod.Projection.Projection (class IsProjection, ProjectionWriteOps, add, coerce, delete)
import Core.Mod.Projection.SearchIndex (EveryTextIndexesWithWeightA, FullTextIndexOnlyB, InvertedIndexOnly, RawIndexOnly, everyTextIndexesWithWeightA, fullTextIndexOnlyWithWeightB, invertedIndexOnly, rawIndexOnly)
import Core.Mod.Projection.SyncProject (SyncProject)
import Core.Util.Validation (class IsRefinedType)
import Yoga.JSON (class ReadForeign, class WriteForeign, readImpl)
import Data.Either (Either(..))
import Data.Generic.Rep (class Generic)
import Data.Maybe (Maybe)
import Data.Newtype (class Newtype)
import Data.Show.Generic (genericShow)
import Run (Run)
import Type.Row (type (+))
import Util.Type.Random (class Random, random)
import Util.Type.String.ToString (toString)

data SearchAuthorsProjection

instance
  IsProjection
    SearchAuthorsProjection
    "searchAuthors"
    "searchAuthorsProjectionWriteOps"
    (SEARCH_AUTHORS_PROJECTION_WRITE_OPS ())
    "searchAuthorsProjectionReadSyncProject"
    { searchAuthors :: Author }
    { searchAuthors :: AuthorIndexNeeds }
    { searchAuthors :: Record AuthorSortRow }
  where
  indexNeeds =
    { searchAuthors:
        { id: rawIndexOnly
        , name: everyTextIndexesWithWeightA
        , biography: fullTextIndexOnlyWithWeightB
        , legacyIds: invertedIndexOnly
        }
    }

  play = coerce @(SEARCH_AUTHORS_PROJECTION_WRITE_OPS ()) play

type SEARCH_AUTHORS_PROJECTION_WRITE_OPS fx = (searchAuthorsProjectionWriteOps :: ProjectionWriteOps | fx)
type SEARCH_AUTHORS_PROJECTION_READ_SYNC_PROJECT fx = (searchAuthorsProjectionReadSyncProject :: SyncProject | fx)

-- Model 

type AuthorSortRow =
  ( name :: Ɩ
  )

---- Author 

instance IsPair AuthorKey Author AuthorRecord AuthorIndexNeeds AuthorSortRow "searchAuthors" "searchAuthorsAuthors" "searchAuthorsProjectionReadFind" SearchAuthorsProjection where
  toKey (Author { id }) = AuthorKey id

  single = false

newtype Author = Author AuthorRecord

type AuthorRecord =
  { id :: AuthorId
  , name :: Name
  , biography :: Biography
  , legacyIds :: LegacyIds
  , portrait :: Maybe Image
  }

type AuthorIndexNeeds =
  { id :: RawIndexOnly AuthorId
  , name :: EveryTextIndexesWithWeightA Name
  , biography :: FullTextIndexOnlyB Biography
  , legacyIds :: InvertedIndexOnly LegacyIds
  }

derive instance Newtype Author _
derive instance Generic Author _
derive instance Eq Author
derive instance Ord Author
derive newtype instance ReadForeign Author
derive newtype instance WriteForeign Author
derive newtype instance Random Author

newtype AuthorKey = AuthorKey AuthorId

derive instance Newtype AuthorKey _
instance ToAliasedPrimary AuthorKey where
  toAliasedPrimary (AuthorKey id) = { primary: toString id, aliases: [] }
derive newtype instance Eq AuthorKey
derive newtype instance Ord AuthorKey

-- Filter

data AuthorFilter
  = AuthorHasId AuthorId
  | AuthorHasLegacyId Int
  | AuthorHasName { name :: Name, weight :: Weight }
  | AuthorHasExactName Name
  | AuthorAnd { left :: AuthorFilter, right :: AuthorFilter }
  | AuthorOr { left :: AuthorFilter, right :: AuthorFilter }
  | AuthorNot AuthorFilter
  | AuthorTrue
  | AuthorFalse

derive instance Eq AuthorFilter
derive instance Ord AuthorFilter
derive instance Generic AuthorFilter _

instance Show AuthorFilter where
  show filter = genericShow filter

instance WriteForeign AuthorFilter where
  writeImpl filter = (genericWriteForeignTaggedSum defaultOptions) filter

instance ReadForeign AuthorFilter where
  readImpl json = (genericReadForeignTaggedSum defaultOptions) json

instance HeytingAlgebra AuthorFilter where
  ff = AuthorFalse
  tt = AuthorTrue
  not = AuthorNot
  implies a b = (AuthorNot a) || b
  conj left right = AuthorAnd { left, right }
  disj left right = AuthorOr { left, right }

instance IsFilter AuthorFilter Author where
  compile _ (AuthorHasId id) = by @"id" StrictlyEquals id

  compile _ (AuthorHasLegacyId legacyId) = by @"legacyIds" Contains [ legacyId ]

  compile e (AuthorHasName { name: name, weight: w }) = by @"name" (Matches { weight: w, expectation: e }) name

  compile _ (AuthorHasExactName name) = by @"name" EqualsUpToNormalization name

  compile e (AuthorAnd { left: f1, right: f2 }) =
    (compile e f1)
      && (compile e f2)

  compile e (AuthorOr { left: f1, right: f2 }) =
    (compile e f1)
      || (compile e f2)

  compile e (AuthorNot f) = not (compile e f)
  
  compile _ AuthorTrue = Base.True
  compile _ AuthorFalse = Base.False

instance IsRefinedType AuthorFilter (InvalidAuthorFilterRow ()) where
  makeFromJson _ json = case Control.Monad.Except.runExcept (readImpl json) of
    Left _ -> Left $ inj InvalidAuthorFilter
    Right filter -> η filter

instance Random AuthorFilter where
  random = AuthorHasId <$> random

-- Find

type SEARCH_AUTHORS_PROJECTION_READ_FIND fx = (searchAuthorsProjectionReadFind :: Find Author | fx)
type SEARCH_AUTHORS_PROJECTION_READ fx =
  SEARCH_AUTHORS_PROJECTION_READ_FIND
    + SEARCH_AUTHORS_PROJECTION_READ_SYNC_PROJECT
    + fx

findAuthors
  :: ∀ fx
   . FindOpt AuthorFilter AuthorId Author
  -> Run (SEARCH_AUTHORS_PROJECTION_READ + fx) (Page Author)
findAuthors opt = findMany_ opt { after = opt.after <#> AuthorKey ▷ persistenceKeyFromKey }

-- Play 

play :: ∀ fx. LoadedEvent -> Run (SEARCH_AUTHORS_PROJECTION_WRITE_OPS fx) Ɩ
play { event } = case event of
  AuthorReferenced payload -> onAuthorReferenced payload
  AuthorDereferenced payload -> onAuthorDereferenced payload
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
  NewsletterScheduled _ -> ηι
  MagazineCustomSectionAdded _ -> ηι
  UserDonated _ -> ηι

---- Listeners

onAuthorReferenced :: ∀ fx. AuthorReferenced.Payload -> Run (SEARCH_AUTHORS_PROJECTION_WRITE_OPS fx) Ɩ
onAuthorReferenced { id, name, biography, legacyIds, portrait } = add $ Author { id, name, biography, legacyIds, portrait }

onAuthorDereferenced :: ∀ fx. AuthorDereferenced.Payload -> Run (SEARCH_AUTHORS_PROJECTION_WRITE_OPS fx) Ɩ
onAuthorDereferenced { author } = delete $ AuthorKey author


