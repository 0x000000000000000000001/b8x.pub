module Core.Feat.Reference.Message.Query.SearchAuthors.Projection.Projection where

import Yoga.JSON.Generics (genericWriteForeignTaggedSum, genericReadForeignTaggedSum)
import Yoga.JSON.Generics.TaggedSumRep (defaultOptions)
import Proem hiding (add)
import Control.Monad.Except as Control.Monad.Except

import Core.Event.AuthorBiographyCorrected.Payload as AuthorBiographyCorrected
import Core.Event.AuthorDereferenced.Payload as AuthorDereferenced
import Core.Event.AuthorReferenced.Payload as AuthorReferenced
import Core.Event.BookDereferenced.Payload as BookDereferenced
import Core.Event.BookReferenced.Payload as BookReferenced
import Core.Event.Event (Event(..), LoadedEvent)
import Core.Exception.Exception (inj)
import Core.Mod.Author.Biography.Biography (Biography)
import Core.Mod.Author.Id.Id (AuthorId)
import Core.Mod.Author.LegacyIds.LegacyIds (LegacyIds)
import Core.Mod.Author.Name.Name (Name)
import Core.Mod.Book.Id.Id (BookId)
import Core.Mod.Book.Name.Name as BookName
import Core.Mod.Image.Image (Image)
import Core.Feat.Reference.Message.Query.SearchAuthors.Projection.Exception.InvalidAuthorFilter (InvalidAuthorFilter(..), InvalidAuthorFilterRow)
import Core.Mod.Projection.Finder.Filter (class IsFilter, Contains(..), EqualsUpToNormalization(..), Matches(..), StrictlyEquals(..), Weight, by, compile)
import Core.Mod.Projection.Finder.Filter as Base
import Core.Mod.Projection.Finder.Finder (Find, FindOpt, Page, findMany_)
import Core.Mod.Projection.Pair (class IsPair, class ToPrimary, class ToAliases, persistenceKeyFromKey)
import Core.Mod.Projection.Projection (class IsProjection, ProjectionWriteOps, add, coerce, delete, patch, get)
import Core.Mod.Projection.SearchIndex (EveryTextIndexesWithWeightA, FullTextIndexOnlyB, InvertedIndexOnly, RawIndexOnly, everyTextIndexesWithWeightA, fullTextIndexOnlyWithWeightB, invertedIndexOnly, rawIndexOnly)
import Core.Mod.Projection.SyncProject (SyncProject)
import Core.Util.Validation (class IsRefinedType)
import Data.Array as Array
import Yoga.JSON (class ReadForeign, class WriteForeign, readImpl)
import Data.Either (Either(..))
import Data.Foldable (for_)
import Data.Generic.Rep (class Generic)
import Data.Maybe (Maybe(..), fromMaybe)
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
    { author :: Author }
    { author :: AuthorIndexNeeds }
    { author :: Record AuthorSortRow }
  where
  indexNeeds =
    { author:
        { id: rawIndexOnly
        , name: everyTextIndexesWithWeightA
        , biography: fullTextIndexOnlyWithWeightB
        , legacyIds: invertedIndexOnly
        , books:
            { ids: rawIndexOnly
            , names: rawIndexOnly
            }
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

instance IsPair AuthorKey Author AuthorRecord AuthorIndexNeeds AuthorSortRow "author" "authors" "searchAuthorsProjectionReadFind" SearchAuthorsProjection where
  toKey (Author { id }) = AuthorKey id

  single = false

newtype Author = Author AuthorRecord

instance ToAliases Author where
  toAliases _ = []

type AuthorBooks =
  { ids :: Array BookId
  , names :: Array BookName.Name
  }

type AuthorRecord =
  { id :: AuthorId
  , name :: Name
  , biography :: Biography
  , legacyIds :: LegacyIds
  , portrait :: Maybe Image
  , books :: AuthorBooks
  }

type AuthorIndexNeeds =
  { id :: RawIndexOnly AuthorId
  , name :: EveryTextIndexesWithWeightA Name
  , biography :: FullTextIndexOnlyB Biography
  , legacyIds :: InvertedIndexOnly LegacyIds
  , books ::
      { ids :: RawIndexOnly (Array BookId)
      , names :: RawIndexOnly (Array BookName.Name)
      }
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
instance ToPrimary AuthorKey where
  toPrimary (AuthorKey id) = toString id

derive newtype instance Eq AuthorKey
derive newtype instance Ord AuthorKey

---- Book 

instance IsPair BookKey Book BookRecord BookIndexNeeds () "book" "books" "searchAuthorsBookProjectionReadFind" SearchAuthorsProjection where
  toKey (Book { id }) = BookKey id

  single = false

newtype Book = Book BookRecord

instance ToAliases Book where
  toAliases _ = []

type BookRecord =
  { id :: BookId
  , authors :: Array AuthorId
  }

type BookIndexNeeds = {}

derive instance Newtype Book _
derive instance Generic Book _
derive instance Eq Book
derive instance Ord Book
derive newtype instance ReadForeign Book
derive newtype instance WriteForeign Book

instance Random Book where
  random = do
    id <- random
    authors <- random
    η $ Book { id, authors }

instance Show Book where
  show = genericShow

newtype BookKey = BookKey BookId

derive newtype instance Eq BookKey
derive newtype instance Ord BookKey
derive newtype instance Random BookKey
derive instance Generic BookKey _

instance Show BookKey where
  show = genericShow

instance ToPrimary BookKey where
  toPrimary (BookKey id) = toString id

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
  BookReferenced payload -> onBookReferenced payload
  BookDereferenced payload -> onBookDereferenced payload
  BookEditorCorrected _ -> ηι
  BookCoverCorrected _ -> ηι
  ArticleTitleCorrected _ -> ηι
  ArticleContentCorrected _ -> ηι
  AuthorBiographyCorrected payload -> onAuthorBiographyCorrected payload
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
onAuthorReferenced { id, name, biography, legacyIds, portrait } = add $ Author { id, name, biography, legacyIds, portrait, books: { ids: [], names: [] } }

onAuthorDereferenced :: ∀ fx. AuthorDereferenced.Payload -> Run (SEARCH_AUTHORS_PROJECTION_WRITE_OPS fx) Ɩ
onAuthorDereferenced { author } = delete $ AuthorKey author

onAuthorBiographyCorrected :: ∀ fx. AuthorBiographyCorrected.Payload -> Run (SEARCH_AUTHORS_PROJECTION_WRITE_OPS fx) Ɩ
onAuthorBiographyCorrected { author, biography } = patch (AuthorKey author) \(Author a) -> Author (a { biography = biography })

onBookReferenced :: ∀ fx. BookReferenced.Payload -> Run (SEARCH_AUTHORS_PROJECTION_WRITE_OPS fx) Ɩ
onBookReferenced payload = do
  add $ Book { id: payload.id, authors: payload.authors }
  for_ payload.authors \authorId -> do
    patch (AuthorKey authorId) \(Author r) ->
      let
        idx = Array.findIndex (_ == payload.id) r.books.ids
      in
        case idx of
          Nothing -> Author (r { books { ids = Array.snoc r.books.ids payload.id, names = Array.snoc r.books.names payload.name } })
          Just _ -> Author r

onBookDereferenced :: ∀ fx. BookDereferenced.Payload -> Run (SEARCH_AUTHORS_PROJECTION_WRITE_OPS fx) Ɩ
onBookDereferenced payload = do
  get (BookKey payload.book) >>= case _ of
    Nothing -> ηι
    Just (Book book) -> do
      for_ book.authors \authorId -> do
        patch (AuthorKey authorId) \(Author r) ->
          let
            idx = Array.findIndex (_ == payload.book) r.books.ids
          in
            case idx of
              Nothing -> Author r
              Just i ->
                let
                  newIds = fromMaybe r.books.ids (Array.deleteAt i r.books.ids)
                  newNames = fromMaybe r.books.names (Array.deleteAt i r.books.names)
                in
                  Author (r { books { ids = newIds, names = newNames } })
      delete (BookKey payload.book)
