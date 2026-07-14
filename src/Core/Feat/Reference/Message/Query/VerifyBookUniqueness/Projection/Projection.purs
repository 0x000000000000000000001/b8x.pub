module Core.Feat.Reference.Message.Query.VerifyBookUniqueness.Projection.Projection where

import Proem hiding (add)

import Core.Event.BookDereferenced.Payload as BookDereferenced
import Core.Event.BookReferenced.Payload as BookReferenced
import Core.Event.Event (Event(..), LoadedEvent)
import Core.Mod.Projection.Finder.Expectation.Expectation (Expectation(..))
import Core.Mod.Author.Id.Id (AuthorId)
import Core.Mod.Book.Id.Id (BookId)
import Core.Mod.Book.Name.Name (Name)
import Core.Mod.Editor.Id.Id (EditorId)
import Core.Mod.Projection.Finder.Filter (Matches(..), noLimit)
import Core.Mod.Projection.Finder.Finder (Find, findManyBy)
import Core.Mod.Projection.Pair (class IsPair, class ToAliasedPrimary)
import Core.Mod.Projection.Projection (class IsProjection, ProjectionWriteOps, add, delete, coerce, noAfter)
import Core.Mod.Projection.SearchIndex (EveryTextIndexesWithWeightA, RawIndexOnly, everyTextIndexesWithWeightA, rawIndexOnly)
import Core.Mod.Projection.SyncProject (SyncProject)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Generic.Rep (class Generic)
import Data.Maybe (Maybe)
import Data.Newtype (class Newtype)
import Run (Run)
import Type.Row (type (+))
import Util.Type.String.ToString (toString)

data VerifyBookUniquenessProjection

instance
  IsProjection
    VerifyBookUniquenessProjection
    "verifyBookUniqueness"
    "verifyBookUniquenessProjectionWriteOps"
    (VERIFY_BOOK_UNIQUENESS_PROJECTION_WRITE_OPS ())
    "verifyBookUniquenessProjectionReadSyncProject"
    { verifyBookUniqueness :: Book }
    { verifyBookUniqueness :: BookIndexNeeds }
    { verifyBookUniqueness :: Record () }
  where
  indexNeeds =
    { verifyBookUniqueness:
        { id: rawIndexOnly
        , name: everyTextIndexesWithWeightA
        }
    }

  play = coerce @(VERIFY_BOOK_UNIQUENESS_PROJECTION_WRITE_OPS ()) play

type VERIFY_BOOK_UNIQUENESS_PROJECTION_WRITE_OPS fx = (verifyBookUniquenessProjectionWriteOps :: ProjectionWriteOps | fx)
type VERIFY_BOOK_UNIQUENESS_PROJECTION_READ_SYNC_PROJECT fx = (verifyBookUniquenessProjectionReadSyncProject :: SyncProject | fx)

-- Model

instance
  IsPair
    BookKey
    Book
    BookRecord
    BookIndexNeeds
    ()
    "verifyBookUniqueness"
    "verifyBookUniquenessBooks"
    "verifyBookUniquenessProjectionReadFind"
    VerifyBookUniquenessProjection
  where
  toKey (Book { id }) = BookKey id
  single = false

newtype Book = Book BookRecord

type BookRecord =
  { id :: BookId
  , name :: Name
  , authors :: Array AuthorId
  , editor :: Maybe EditorId
  }

type BookIndexNeeds =
  { id :: RawIndexOnly BookId
  , name :: EveryTextIndexesWithWeightA Name
  }

derive instance Newtype Book _
derive instance Generic Book _
derive instance Eq Book
derive instance Ord Book
derive newtype instance ReadForeign Book
derive newtype instance WriteForeign Book
derive newtype instance Show Book

newtype BookKey = BookKey BookId

derive instance Newtype BookKey _
instance ToAliasedPrimary BookKey where
  toAliasedPrimary (BookKey id) = { primary: toString id, aliases: [] }
derive newtype instance Eq BookKey
derive newtype instance Ord BookKey

-- Find

type VERIFY_BOOK_UNIQUENESS_PROJECTION_READ_FIND fx = (verifyBookUniquenessProjectionReadFind :: Find Book | fx)
type VERIFY_BOOK_UNIQUENESS_PROJECTION_READ fx =
  VERIFY_BOOK_UNIQUENESS_PROJECTION_READ_FIND
    + VERIFY_BOOK_UNIQUENESS_PROJECTION_READ_SYNC_PROJECT
    + fx

findBooksByName
  :: ∀ fx
   . Name
  -> Run (VERIFY_BOOK_UNIQUENESS_PROJECTION_READ + fx) (Array Book)
findBooksByName name = findManyBy @Book @"name" (Matches { weight: 1.0, expectation: QuickNothingBetterThanSlowerSomething }) name noLimit noAfter

-- Play

play :: ∀ fx. LoadedEvent -> Run (VERIFY_BOOK_UNIQUENESS_PROJECTION_WRITE_OPS fx) Ɩ
play { event } = case event of
  BookReferenced payload -> onBookReferenced payload
  BookDereferenced payload -> onBookDereferenced payload
  AuthorReferenced _ -> ηι
  AuthorDereferenced _ -> ηι
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

onBookReferenced :: ∀ fx. BookReferenced.Payload -> Run (VERIFY_BOOK_UNIQUENESS_PROJECTION_WRITE_OPS fx) Ɩ
onBookReferenced { id, name, authors, editor } = add $ Book { id, name, authors, editor }

onBookDereferenced :: ∀ fx. BookDereferenced.Payload -> Run (VERIFY_BOOK_UNIQUENESS_PROJECTION_WRITE_OPS fx) Ɩ
onBookDereferenced { book } = delete $ BookKey book
