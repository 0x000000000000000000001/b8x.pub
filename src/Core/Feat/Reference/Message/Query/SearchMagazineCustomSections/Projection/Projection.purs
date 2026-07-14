module Core.Feat.Reference.Message.Query.SearchMagazineCustomSections.Projection.Projection where

import Yoga.JSON.Generics (genericWriteForeignTaggedSum, genericReadForeignTaggedSum)
import Yoga.JSON.Generics.TaggedSumRep (defaultOptions)
import Proem hiding (add)
import Control.Monad.Except as Control.Monad.Except

import Core.Event.MagazineCustomSectionAdded.Payload as MagazineCustomSectionAdded
import Core.Event.Event (Event(..), LoadedEvent)
import Core.Exception.Exception (inj)
import Core.Mod.MagazineIssue.CustomSection.Id.Id (CustomSectionId)
import Core.Mod.MagazineIssue.Id.Id (MagazineIssueId)
import Core.Mod.MagazineIssue.CustomSection.Name.Name as CustomSectionName
import Core.Mod.Projection.Finder.Finder (Find, FindOpt, Page, findMany_)
import Core.Mod.Projection.Finder.Filter (class IsFilter, EqualsUpToNormalization(..), Matches(..), StrictlyEquals(..), Weight, by, compile)
import Core.Mod.Projection.Finder.Filter as Base
import Core.Mod.Projection.Pair (class IsPair, class ToAliasedPrimary, persistenceKeyFromKey)
import Core.Mod.Projection.Projection (class IsProjection, ProjectionWriteOps, add, coerce)
import Core.Mod.Projection.SearchIndex (EveryTextIndexesWithWeightA, RawIndexOnly, everyTextIndexesWithWeightA, rawIndexOnly)
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
import Core.Feat.Reference.Message.Query.SearchMagazineCustomSections.Exception.InvalidCustomSectionFilter (InvalidCustomSectionFilter(..), InvalidCustomSectionFilterRow)

data SearchMagazineCustomSectionsProjection

instance
  IsProjection
    SearchMagazineCustomSectionsProjection
    "searchMagazineCustomSections"
    "searchMagazineCustomSectionsProjectionWriteOps"
    (SEARCH_MAGAZINE_CUSTOM_SECTIONS_PROJECTION_WRITE_OPS ())
    "searchMagazineCustomSectionsProjectionReadSyncProject"
    { customSection :: CustomSection
    }
    { customSection :: CustomSectionIndexNeeds
    }
    { customSection :: Record ()
    }
  where
  indexNeeds =
    { customSection:
        { id: rawIndexOnly
        , magazineIssue: rawIndexOnly
        , name: everyTextIndexesWithWeightA
        }
    }

  play = coerce @(SEARCH_MAGAZINE_CUSTOM_SECTIONS_PROJECTION_WRITE_OPS ()) play

type SEARCH_MAGAZINE_CUSTOM_SECTIONS_PROJECTION_WRITE_OPS fx = (searchMagazineCustomSectionsProjectionWriteOps :: ProjectionWriteOps | fx)
type SEARCH_MAGAZINE_CUSTOM_SECTIONS_PROJECTION_READ_SYNC_PROJECT fx = (searchMagazineCustomSectionsProjectionReadSyncProject :: SyncProject | fx)

type SEARCH_MAGAZINE_CUSTOM_SECTIONS_PROJECTION_READ_FIND fx =
  SEARCH_MAGAZINE_CUSTOM_SECTIONS_CUSTOM_SECTION_PROJECTION_READ_FIND
    + fx

-- Model

---- CustomSection

instance IsPair CustomSectionKey CustomSection CustomSectionRecord CustomSectionIndexNeeds () "customSection" "customSections" "searchMagazineCustomSectionsCustomSectionProjectionReadFind" SearchMagazineCustomSectionsProjection where
  toKey (CustomSection { id }) = CustomSectionKey id

  single = false

newtype CustomSection = CustomSection CustomSectionRecord

type CustomSectionRecord =
  { id :: CustomSectionId
  , magazineIssue :: MagazineIssueId
  , name :: CustomSectionName.Name
  }

type CustomSectionIndexNeeds =
  { id :: RawIndexOnly CustomSectionId
  , magazineIssue :: RawIndexOnly MagazineIssueId
  , name :: EveryTextIndexesWithWeightA CustomSectionName.Name
  }

derive instance Newtype CustomSection _
derive instance Generic CustomSection _
derive instance Eq CustomSection
derive instance Ord CustomSection
derive newtype instance ReadForeign CustomSection
derive newtype instance WriteForeign CustomSection
derive newtype instance Random CustomSection

instance Show CustomSection where
  show = genericShow

newtype CustomSectionKey = CustomSectionKey CustomSectionId

derive instance Newtype CustomSectionKey _
instance ToAliasedPrimary CustomSectionKey where
  toAliasedPrimary (CustomSectionKey id) = { primary: toString id, aliases: [] }
derive newtype instance Eq CustomSectionKey
derive newtype instance Ord CustomSectionKey
derive instance Generic CustomSectionKey _

instance Show CustomSectionKey where
  show = genericShow

-- Find

type SEARCH_MAGAZINE_CUSTOM_SECTIONS_CUSTOM_SECTION_PROJECTION_READ_FIND fx = (searchMagazineCustomSectionsCustomSectionProjectionReadFind :: Find CustomSection | fx)
type SEARCH_MAGAZINE_CUSTOM_SECTIONS_CUSTOM_SECTION_PROJECTION_READ fx =
  SEARCH_MAGAZINE_CUSTOM_SECTIONS_CUSTOM_SECTION_PROJECTION_READ_FIND
    + SEARCH_MAGAZINE_CUSTOM_SECTIONS_PROJECTION_READ_SYNC_PROJECT
    + fx

findCustomSections
  :: ∀ fx
   . FindOpt CustomSectionFilter CustomSectionId CustomSection
  -> Run (SEARCH_MAGAZINE_CUSTOM_SECTIONS_CUSTOM_SECTION_PROJECTION_READ + fx) (Page CustomSection)
findCustomSections opt = findMany_ opt { after = opt.after <#> CustomSectionKey ▷ persistenceKeyFromKey }

-- Filter

data CustomSectionFilter
  = CustomSectionHasId CustomSectionId
  | CustomSectionHasMagazineIssue MagazineIssueId
  | CustomSectionHasName { name :: CustomSectionName.Name, weight :: Weight }
  | CustomSectionHasExactName CustomSectionName.Name
  | CustomSectionAnd { left :: CustomSectionFilter, right :: CustomSectionFilter }
  | CustomSectionOr { left :: CustomSectionFilter, right :: CustomSectionFilter }
  | CustomSectionNot CustomSectionFilter
  | CustomSectionTrue
  | CustomSectionFalse

derive instance Eq CustomSectionFilter
derive instance Ord CustomSectionFilter
derive instance Generic CustomSectionFilter _

instance Show CustomSectionFilter where
  show filter = genericShow filter

instance WriteForeign CustomSectionFilter where
  writeImpl filter = (genericWriteForeignTaggedSum defaultOptions) filter

instance ReadForeign CustomSectionFilter where
  readImpl json = (genericReadForeignTaggedSum defaultOptions) json

instance HeytingAlgebra CustomSectionFilter where
  ff = CustomSectionFalse
  tt = CustomSectionTrue
  not = CustomSectionNot
  implies a b = CustomSectionOr { left: CustomSectionNot a, right: b }
  conj left right = CustomSectionAnd { left, right }
  disj left right = CustomSectionOr { left, right }

instance IsFilter CustomSectionFilter CustomSection where
  compile _ (CustomSectionHasId id) = by @"id" StrictlyEquals id

  compile _ (CustomSectionHasMagazineIssue issue) = by @"magazineIssue" StrictlyEquals issue

  compile e (CustomSectionHasName { name: name, weight: w }) = by @"name" (Matches { weight: w, expectation: e }) name

  compile _ (CustomSectionHasExactName name) = by @"name" EqualsUpToNormalization name

  compile e (CustomSectionAnd { left: f1, right: f2 }) =
    (compile e f1)
      && (compile e f2)

  compile e (CustomSectionOr { left: f1, right: f2 }) =
    (compile e f1)
      || (compile e f2)

  compile e (CustomSectionNot f) = not (compile e f)

  compile _ CustomSectionTrue = Base.True
  compile _ CustomSectionFalse = Base.False

instance IsRefinedType CustomSectionFilter (InvalidCustomSectionFilterRow ()) where
  makeFromJson _ json = case Control.Monad.Except.runExcept (readImpl json) of
    Left _ -> Left $ inj InvalidCustomSectionFilter
    Right filter -> η filter

instance Random CustomSectionFilter where
  random = CustomSectionHasId <$> random

-- Play 

play :: ∀ fx. LoadedEvent -> Run (SEARCH_MAGAZINE_CUSTOM_SECTIONS_PROJECTION_WRITE_OPS fx) Ɩ
play { event } = case event of
  MagazineCustomSectionAdded payload -> onMagazineCustomSectionAdded payload
  UserDonated _ -> ηι
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
  NewsletterScheduled _ -> ηι

---- Listeners

onMagazineCustomSectionAdded :: ∀ fx. MagazineCustomSectionAdded.Payload -> Run (SEARCH_MAGAZINE_CUSTOM_SECTIONS_PROJECTION_WRITE_OPS fx) Ɩ
onMagazineCustomSectionAdded { id, magazineIssue, name } = add $ CustomSection { id, magazineIssue, name }


