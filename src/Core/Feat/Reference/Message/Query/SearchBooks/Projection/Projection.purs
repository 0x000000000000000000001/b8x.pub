module Core.Feat.Reference.Message.Query.SearchBooks.Projection.Projection where

import Yoga.JSON.Generics (genericWriteForeignTaggedSum, genericReadForeignTaggedSum)
import Yoga.JSON.Generics.TaggedSumRep (defaultOptions)
import Proem hiding (add)
import Control.Monad.Except as Control.Monad.Except

import Core.Event.BookDereferenced.Payload as BookDereferenced
import Core.Event.BookReferenced.Payload as BookReferenced
import Core.Event.Event (Event(..), LoadedEvent)
import Core.Exception.Exception (inj)
import Core.Mod.Author.Id.Id (AuthorId)
import Core.Mod.Book.Id.Id (BookId)
import Core.Mod.Time.Year as Time
import Core.Mod.Book.Name.Name (Name)
import Core.Feat.Reference.Message.Query.SearchBooks.Exception.InvalidBookFilter (InvalidBookFilter(..), InvalidBookFilterRow)
import Core.Mod.Book.Year.Year (Year)
import Core.Mod.Editor.Id.Id (EditorId)
import Core.Mod.Image.Image (Image)
import Core.Mod.Projection.Finder.Filter (class IsFilter, EqualsUpToNormalization(..), Matches(..), StrictlyEquals(..), Weight, by, compile)
import Core.Mod.Projection.Finder.Filter as Base
import Core.Mod.Projection.Finder.Finder (Find, FindOpt, Page, findMany_)
import Core.Mod.Projection.Pair (class IsPair, class ToAliasedPrimary, persistenceKeyFromKey)
import Core.Mod.Projection.Projection (class IsProjection, ProjectionWriteOps, add, coerce, delete)
import Core.Mod.Projection.SearchIndex (EveryTextIndexesWithWeightA, RawIndexOnly, everyTextIndexesWithWeightA, rawIndexOnly)
import Core.Mod.Projection.SyncProject (SyncProject)
import Core.Util.Validation (class IsRefinedType)
import Yoga.JSON (class ReadForeign, class WriteForeign, readImpl)
import Data.Either (Either(..))
import Data.Generic.Rep (class Generic)
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)
import Data.Show.Generic (genericShow)
import Run (Run)
import Type.Row (type (+))
import Util.Type.Random (class Random, random)
import Util.Type.String.ToString (toString)

data SearchBooksProjection

instance
  IsProjection
    SearchBooksProjection
    "searchBooks"
    "searchBooksProjectionWriteOps"
    (SEARCH_BOOKS_PROJECTION_WRITE_OPS ())
    "searchBooksProjectionReadSyncProject"
    { searchBooks :: Book }
    { searchBooks :: BookIndexNeeds }
    { searchBooks :: Record BookSortRow }
  where
  indexNeeds =
    { searchBooks:
        { id: rawIndexOnly
        , name: everyTextIndexesWithWeightA
        , year:
            { year: rawIndexOnly
            , approximately: rawIndexOnly
            }
        , legacyId: rawIndexOnly
        }
    }

  play = coerce @(SEARCH_BOOKS_PROJECTION_WRITE_OPS ()) play

type SEARCH_BOOKS_PROJECTION_WRITE_OPS fx = (searchBooksProjectionWriteOps :: ProjectionWriteOps | fx)
type SEARCH_BOOKS_PROJECTION_READ_SYNC_PROJECT fx = (searchBooksProjectionReadSyncProject :: SyncProject | fx)

-- Model 

type BookSortRow =
  ( "year.year" :: Ɩ
  , name :: Ɩ
  )

instance IsPair BookKey Book BookRecord BookIndexNeeds BookSortRow "searchBooks" "searchBooksBooks" "searchBooksProjectionReadFind" SearchBooksProjection where
  toKey (Book { id }) = BookKey id

  single = false

newtype Book = Book BookRecord

type BookRecord =
  { id :: BookId
  , name :: Name
  , year :: Maybe Year
  , cover :: Maybe Image
  , authors :: Array AuthorId
  , editor :: Maybe EditorId
  , legacyId :: Maybe Int
  }

type BookIndexNeeds =
  { id :: RawIndexOnly BookId
  , name :: EveryTextIndexesWithWeightA Name
  , year ::
      { year :: RawIndexOnly Time.Year
      , approximately :: RawIndexOnly Boolean
      }
  , legacyId :: RawIndexOnly (Maybe Int)
  }

derive instance Newtype Book _
derive instance Generic Book _
derive instance Eq Book
derive instance Ord Book
derive newtype instance ReadForeign Book
derive newtype instance WriteForeign Book
derive newtype instance Random Book

newtype BookKey = BookKey BookId

derive instance Newtype BookKey _
instance ToAliasedPrimary BookKey where
  toAliasedPrimary (BookKey id) = { primary: toString id, aliases: [] }
derive newtype instance Eq BookKey
derive newtype instance Ord BookKey

-- Filter

data BookFilter
  = BookHasId BookId
  | BookHasYear Time.Year
  | BookHasName { name :: Name, weight :: Weight }
  | BookHasExactName Name
  | BookHasLegacyId Int
  | BookAnd { left :: BookFilter, right :: BookFilter }
  | BookOr { left :: BookFilter, right :: BookFilter }
  | BookNot BookFilter
  | BookTrue
  | BookFalse

derive instance Eq BookFilter
derive instance Ord BookFilter
derive instance Generic BookFilter _

instance Show BookFilter where
  show filter = genericShow filter

instance WriteForeign BookFilter where
  writeImpl filter = (genericWriteForeignTaggedSum defaultOptions) filter

instance ReadForeign BookFilter where
  readImpl json = (genericReadForeignTaggedSum defaultOptions) json

instance HeytingAlgebra BookFilter where
  ff = BookFalse
  tt = BookTrue
  not = BookNot
  implies a b = (BookNot a) || b
  conj left right = BookAnd { left, right }
  disj left right = BookOr { left, right }

instance IsFilter BookFilter Book where
  compile _ (BookHasId id) = by @"id" StrictlyEquals id
  compile _ (BookHasYear year) = by @"year.year" StrictlyEquals year

  compile e (BookHasName { name: name, weight: w }) = by @"name" (Matches { weight: w, expectation: e }) name
  compile _ (BookHasExactName name) = by @"name" EqualsUpToNormalization name

  compile _ (BookHasLegacyId legacyId) = by @"legacyId" StrictlyEquals (Just legacyId)

  compile e (BookAnd { left: f1, right: f2 }) =
    (compile e f1)
      && (compile e f2)

  compile e (BookOr { left: f1, right: f2 }) =
    (compile e f1)
      || (compile e f2)

  compile e (BookNot f) = not (compile e f)

  compile _ BookTrue = Base.True
  compile _ BookFalse = Base.False

instance IsRefinedType BookFilter (InvalidBookFilterRow ()) where
  makeFromJson _ json = case Control.Monad.Except.runExcept (readImpl json) of
    Left _ -> Left $ inj InvalidBookFilter
    Right filter -> η filter

instance Random BookFilter where
  random = BookHasId <$> random

-- Find

type SEARCH_BOOKS_PROJECTION_READ_FIND fx = (searchBooksProjectionReadFind :: Find Book | fx)
type SEARCH_BOOKS_PROJECTION_READ fx =
  SEARCH_BOOKS_PROJECTION_READ_FIND
    + SEARCH_BOOKS_PROJECTION_READ_SYNC_PROJECT
    + fx

findBooks
  :: ∀ fx
   . FindOpt BookFilter BookId Book
  -> Run (SEARCH_BOOKS_PROJECTION_READ + fx) (Page Book)
findBooks opt = findMany_ opt { after = opt.after <#> BookKey ▷ persistenceKeyFromKey }

-- Play 

play :: ∀ fx. LoadedEvent -> Run (SEARCH_BOOKS_PROJECTION_WRITE_OPS fx) Ɩ
play { event } = case event of
  BookReferenced payload -> onBookReferenced payload
  BookDereferenced payload -> onBookDereferenced payload
  AuthorReferenced _ -> ηι
  AuthorDereferenced _ -> ηι
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

onBookReferenced :: ∀ fx. BookReferenced.Payload -> Run (SEARCH_BOOKS_PROJECTION_WRITE_OPS fx) Ɩ
onBookReferenced { id, name, year, cover, authors, editor, legacyId } = add $ Book { id, name, year, cover, authors, editor, legacyId }

onBookDereferenced :: ∀ fx. BookDereferenced.Payload -> Run (SEARCH_BOOKS_PROJECTION_WRITE_OPS fx) Ɩ
onBookDereferenced { book } = delete $ BookKey book


