module Core.Feat.Review.Message.Query.ListMostReadArticles.Projection.Projection where

import Yoga.JSON.Generics (genericWriteForeignTaggedSum, genericReadForeignTaggedSum)
import Yoga.JSON.Generics.TaggedSumRep (defaultOptions)
import Proem hiding (add)
import Control.Monad.Except as Control.Monad.Except

import Core.Mod.Author.Biography.Biography (Biography)
import Core.Event.ArticleDiscarded.Payload as ArticleDiscarded
import Core.Event.ArticleRead.Payload as ArticleRead
import Core.Event.ArticleWritten.Payload as ArticleWritten
import Core.Event.AuthorReferenced.Payload as AuthorReferenced
import Core.Event.BookReferenced.Payload as BookReferenced
import Core.Event.EditorReferenced.Payload as EditorReferenced
import Core.Event.Event (Event(..), LoadedEvent)
import Core.Exception.Exception (inj)
import Core.Mod.Article.Content.Content (Content)
import Core.Mod.Article.Id.Id (ArticleId)
import Core.Mod.Article.Lead.Lead (Lead)
import Core.Mod.Article.Notes.Notes (Notes)
import Core.Mod.Article.Projection.Books.Books (Books)
import Core.Mod.Article.Projection.Books.Books as Books
import Core.Mod.Article.Projection.Exception.InvalidArticleFilter (InvalidArticleFilter(..), InvalidArticleFilterRow)
import Core.Mod.Article.Projection.Illustrations (Illustrations)
import Core.Mod.Article.Projection.Illustrations as Illustrations
import Core.Mod.Article.Slug.Slug (Slug)
import Core.Mod.Article.Sources.Sources (Sources)
import Core.Mod.Article.Theme.Theme (Theme)
import Core.Mod.Article.Title.Title (Title)
import Core.Mod.Author.Id.Id (AuthorId)
import Core.Mod.Author.Name.Name (Name)
import Core.Mod.Book.Id.Id (BookId)
import Core.Mod.Book.Year.Year (Year)
import Core.Mod.Editor.Id.Id (EditorId)
import Core.Mod.Editor.Name.Name as EditorName
import Core.Mod.Image.Image (Image)
import Core.Mod.Projection.Finder.Filter (class IsFilter, StrictlyEquals(..), StrictlyNotEquals(..), by, compile)
import Core.Mod.Projection.Finder.Filter as Base
import Core.Mod.Projection.Finder.Finder (Find, FindOpt, Page, findManyByKeys, findMany_, findOneBy, findOneByKey)
import Core.Mod.Projection.Finder.Sort (SortCriteria)
import Core.Mod.Projection.Pair (class IsPair, class ToAliasedPrimary, persistenceKeyFromKey)
import Core.Mod.Projection.Projection (class IsProjection, ProjectionWriteOps, add, coerce, delete, get, patch)
import Core.Mod.Projection.SearchIndex (RawIndexOnly, rawIndexOnly)
import Core.Mod.Projection.SyncProject (SyncProject)
import Core.Mod.Time.Instant (Instant)
import Core.Util.Validation (class IsRefinedType)
import Yoga.JSON (class ReadForeign, class WriteForeign, readImpl)
import Data.Array as Array
import Data.Either (Either(..))
import Data.Generic.Rep (class Generic)
import Data.Map as Map
import Data.Maybe (Maybe(..), maybe)
import Data.Newtype (class Newtype, unwrap, wrap)
import Data.Show.Generic (genericShow)
import Data.Traversable (traverse)
import Data.Tuple (Tuple(..))
import Run (Run)
import Type.Row (type (+))
import Util.Type.Random (class Random, random)
import Util.Type.String.ToString (toString)

data ListMostReadArticlesProjection

instance
  IsProjection
    ListMostReadArticlesProjection
    "listMostReadArticles"
    "listMostReadArticlesProjectionWriteOps"
    (LIST_MOST_READ_ARTICLES_PROJECTION_WRITE_OPS ())
    "listMostReadArticlesProjectionReadSyncProject"
    { article :: Article
    }
    { article :: ArticleIndexNeeds
    }
    { article :: Record ArticleSortRow
    }
  where

  indexNeeds =
    { article:
        { id: rawIndexOnly
        , legacyId: rawIndexOnly
        , theme: rawIndexOnly
        , books:
            { hasAtLeastOneCover: rawIndexOnly
            }
        , writtenAt: rawIndexOnly
        , illustrations:
            { hasAtLeastOne: rawIndexOnly
            }
        , readCount: rawIndexOnly
        }
    }

  play = coerce @(LIST_MOST_READ_ARTICLES_PROJECTION_WRITE_OPS ()) play

type LIST_MOST_READ_ARTICLES_PROJECTION_WRITE_OPS fx = (listMostReadArticlesProjectionWriteOps :: ProjectionWriteOps | fx)
type LIST_MOST_READ_ARTICLES_PROJECTION_READ_SYNC_PROJECT fx = (listMostReadArticlesProjectionReadSyncProject :: SyncProject | fx)
type LIST_MOST_READ_ARTICLES_PROJECTION_READ_FIND fx =
  LIST_MOST_READ_ARTICLES_ARTICLE_PROJECTION_READ_FIND
    + fx

-- Model 

---- Article 

instance IsPair ArticleKey Article ArticleRecord ArticleIndexNeeds ArticleSortRow "article" "articles" "listMostReadArticlesArticleProjectionReadFind" ListMostReadArticlesProjection where
  toKey (Article { id, slug }) = ArticleKey { id: Just id, slug: Just slug }

  single = false

newtype Article = Article ArticleRecord

type ArticleAuthor =
  { id :: AuthorId
  , name :: Name
  , biography :: Biography
  , portrait :: Maybe Image
  }

type ArticleRecord =
  { id :: ArticleId
  , legacyId :: Maybe Int
  , title :: Title
  , lead :: Lead
  , notes :: Notes
  , sources :: Sources
  , content :: Content
  , theme :: Maybe Theme
  , books :: Books
  , author :: Maybe ArticleAuthor
  , illustrations :: Illustrations
  , slug :: Slug
  , writtenAt :: Instant
  , readCount :: Int
  }

type ArticleIndexNeeds =
  { id :: RawIndexOnly ArticleId
  , legacyId :: RawIndexOnly (Maybe Int)
  , theme :: RawIndexOnly (Maybe Theme)
  , books ::
      { hasAtLeastOneCover :: RawIndexOnly Boolean
      }
  , writtenAt :: RawIndexOnly Instant
  , illustrations ::
      { hasAtLeastOne :: RawIndexOnly Boolean
      }
  , readCount :: RawIndexOnly Int
  }

derive instance Newtype Article _
derive instance Generic Article _
derive instance Eq Article
derive instance Ord Article
derive newtype instance ReadForeign Article
derive newtype instance WriteForeign Article

instance Show Article where
  show = genericShow

type ArticleSortRow =
  ( id :: Ɩ
  , writtenAt :: Ɩ
  , readCount :: Ɩ
  )

type ArticleSortCriteria = SortCriteria Article

instance Random Article where
  random = do
    id <- random
    legacyId <- random
    title <- random
    lead <- random
    notes <- random
    sources <- random
    content <- random
    theme <- random
    books <- random
    author <- random
    illustrations <- random
    slug <- random
    writtenAt <- random
    readCount <- random

    η $ Article
      { id
      , legacyId
      , title
      , lead
      , notes
      , sources
      , content
      , theme
      , books
      , author
      , illustrations
      , slug
      , writtenAt
      , readCount
      }

newtype ArticleKey = ArticleKey { id :: Maybe ArticleId, slug :: Maybe Slug }

derive instance Newtype ArticleKey _
instance ToAliasedPrimary ArticleKey where
  toAliasedPrimary (ArticleKey k) = { primary: maybe "" toString k.id, aliases: maybe [] (Array.singleton <<< toString) k.slug }
derive instance Eq ArticleKey
derive instance Ord ArticleKey
derive instance Generic ArticleKey _

instance Show ArticleKey where
  show = genericShow

---- Author 

instance IsPair AuthorKey Author AuthorRecord AuthorIndexNeeds () "author" "authors" "listMostReadArticlesAuthorProjectionReadFind" ListMostReadArticlesProjection where
  toKey (Author { id }) = AuthorKey id

  single = false

newtype Author = Author AuthorRecord

type AuthorRecord =
  { id :: AuthorId
  , name :: Name
  , biography :: Biography
  , portrait :: Maybe Image
  }

type AuthorIndexNeeds = {}

derive instance Newtype Author _
derive instance Generic Author _
derive instance Eq Author
derive instance Ord Author
derive newtype instance ReadForeign Author
derive newtype instance WriteForeign Author
instance Random Author where
  random = do
    id <- random
    name <- random
    biography <- random
    portrait <- random
    η $ Author { id, name, biography, portrait }

instance Show Author where
  show = genericShow

newtype AuthorKey = AuthorKey AuthorId

derive newtype instance Eq AuthorKey
derive newtype instance Ord AuthorKey
derive newtype instance Random AuthorKey
derive instance Generic AuthorKey _

instance Show AuthorKey where
  show = genericShow

instance ToAliasedPrimary AuthorKey where
  toAliasedPrimary (AuthorKey id) = { primary: toString id, aliases: [] }

---- Editor 

instance IsPair EditorKey Editor EditorRecord EditorIndexNeeds () "editor" "editors" "listMostReadArticlesEditorProjectionReadFind" ListMostReadArticlesProjection where
  toKey (Editor { id }) = EditorKey id

  single = false

newtype Editor = Editor EditorRecord

type EditorRecord =
  { id :: EditorId
  , name :: EditorName.Name
  }

type EditorIndexNeeds = {}

derive instance Newtype Editor _
derive instance Generic Editor _
derive instance Eq Editor
derive instance Ord Editor
derive newtype instance ReadForeign Editor
derive newtype instance WriteForeign Editor
derive newtype instance Random Editor

instance Show Editor where
  show = genericShow

newtype EditorKey = EditorKey EditorId

derive newtype instance Eq EditorKey
derive newtype instance Ord EditorKey
derive newtype instance Random EditorKey
derive instance Generic EditorKey _

instance Show EditorKey where
  show = genericShow

instance ToAliasedPrimary EditorKey where
  toAliasedPrimary (EditorKey id) = { primary: toString id, aliases: [] }

---- Book 

instance IsPair BookKey Book BookRecord BookIndexNeeds () "book" "books" "listMostReadArticlesBookProjectionReadFind" ListMostReadArticlesProjection where
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
  }

type BookIndexNeeds = {}

derive instance Newtype Book _
derive instance Generic Book _
derive instance Eq Book
derive instance Ord Book
derive newtype instance ReadForeign Book
derive newtype instance WriteForeign Book
derive newtype instance Random Book

instance Show Book where
  show = genericShow

newtype BookKey = BookKey BookId

derive newtype instance Eq BookKey
derive newtype instance Ord BookKey
derive newtype instance Random BookKey
derive instance Generic BookKey _

instance Show BookKey where
  show = genericShow

instance ToAliasedPrimary BookKey where
  toAliasedPrimary (BookKey id) = { primary: toString id, aliases: [] }

-- Filter

type BookCoverFallbackIncluded = Boolean

data ArticleFilter
  = ArticleHasId ArticleId
  | ArticleHasNotId ArticleId
  | ArticleHasTheme Theme
  | ArticleHasLegacyId Int
  | ArticleIsAboutAtLeastOneBookWithCover
  | ArticleHasAtLeastOneIllustration BookCoverFallbackIncluded
  | ArticleAnd { left :: ArticleFilter, right :: ArticleFilter }
  | ArticleOr { left :: ArticleFilter, right :: ArticleFilter }
  | ArticleNot ArticleFilter
  | ArticleTrue
  | ArticleFalse

derive instance Eq ArticleFilter
derive instance Ord ArticleFilter
derive instance Generic ArticleFilter _

instance Show ArticleFilter where
  show filter = genericShow filter

instance WriteForeign ArticleFilter where
  writeImpl filter = (genericWriteForeignTaggedSum defaultOptions) filter

instance ReadForeign ArticleFilter where
  readImpl json = (genericReadForeignTaggedSum defaultOptions) json

instance HeytingAlgebra ArticleFilter where
  ff = ArticleFalse
  tt = ArticleTrue
  not = ArticleNot
  implies a b = (ArticleNot a) || b
  conj left right = ArticleAnd { left, right }
  disj left right = ArticleOr { left, right }

instance IsFilter ArticleFilter Article where
  compile _ (ArticleHasId id) = by @"id" StrictlyEquals id
  compile _ (ArticleHasNotId id) = by @"id" StrictlyNotEquals id

  compile _ (ArticleHasTheme theme) = by @"theme" StrictlyEquals (Just theme)
  compile _ (ArticleHasLegacyId legacyId) = by @"legacyId" StrictlyEquals (Just legacyId)

  compile _ ArticleIsAboutAtLeastOneBookWithCover = by @"books.hasAtLeastOneCover" StrictlyEquals true

  compile e (ArticleHasAtLeastOneIllustration bookCoverFallbackIncluded) =
    let
      filterHasAtLeastOne = by @"illustrations.hasAtLeastOne" StrictlyEquals true
      filterHasAtLeastOneBook = compile e ArticleIsAboutAtLeastOneBookWithCover
    in
      if bookCoverFallbackIncluded then
        filterHasAtLeastOne || filterHasAtLeastOneBook
      else
        filterHasAtLeastOne

  compile e (ArticleAnd { left: f1, right: f2 }) =
    (compile e f1)
      && (compile e f2)

  compile e (ArticleOr { left: f1, right: f2 }) =
    (compile e f1)
      || (compile e f2)

  compile e (ArticleNot f) = not (compile e f)

  compile _ ArticleTrue = Base.True
  compile _ ArticleFalse = Base.False

instance IsRefinedType ArticleFilter (InvalidArticleFilterRow ()) where
  makeFromJson _ json = case Control.Monad.Except.runExcept (readImpl json) of
    Left _ -> Left $ inj InvalidArticleFilter
    Right filter -> η filter

instance Random ArticleFilter where
  random = ArticleHasId <$> random

-- Find

type LIST_MOST_READ_ARTICLES_ARTICLE_PROJECTION_READ_FIND fx = (listMostReadArticlesArticleProjectionReadFind :: Find Article | fx)
type LIST_MOST_READ_ARTICLES_ARTICLE_PROJECTION_READ fx =
  LIST_MOST_READ_ARTICLES_ARTICLE_PROJECTION_READ_FIND
    + LIST_MOST_READ_ARTICLES_PROJECTION_READ_SYNC_PROJECT
    + fx

findArticleById :: ∀ fx. ArticleId -> Run (LIST_MOST_READ_ARTICLES_ARTICLE_PROJECTION_READ + fx) (Maybe Article)
findArticleById id = findOneByKey (ArticleKey { id: Just id, slug: Nothing })

findArticlesByIds :: ∀ fx. Array ArticleId -> Run (LIST_MOST_READ_ARTICLES_ARTICLE_PROJECTION_READ + fx) (Array Article)
findArticlesByIds ids = findManyByKeys (ids <#> \id -> ArticleKey { id: Just id, slug: Nothing })

findArticleByLegacyId :: ∀ fx. Int -> Run (LIST_MOST_READ_ARTICLES_ARTICLE_PROJECTION_READ + fx) (Maybe Article)
findArticleByLegacyId legacyId = findOneBy @Article @"legacyId" StrictlyEquals (Just legacyId)

findArticles
  :: ∀ fx
   . FindOpt ArticleFilter ArticleId Article
  -> Run (LIST_MOST_READ_ARTICLES_ARTICLE_PROJECTION_READ + fx) (Page Article)
findArticles opt = findMany_ opt { after = opt.after <#> (\id -> ArticleKey { id: Just id, slug: Nothing }) ▷ persistenceKeyFromKey }

-- Play 

play :: ∀ fx. LoadedEvent -> Run (LIST_MOST_READ_ARTICLES_PROJECTION_WRITE_OPS fx) Ɩ
play { event, at } = case event of
  ArticleDiscarded payload -> onArticleDiscarded payload
  ArticleWritten payload -> onArticleWritten at payload
  AuthorReferenced payload -> onAuthorReferenced payload
  EditorReferenced payload -> onEditorReferenced payload
  BookReferenced payload -> onBookReferenced payload
  ArticleRead payload -> onArticleRead payload
  AuthorDereferenced _ -> ηι
  BookDereferenced _ -> ηι
  MagazineIssueReferenced _ -> ηι
  MagazineIssueDereferenced _ -> ηι
  EditorDereferenced _ -> ηι
  UserEmailChanged _ -> ηι
  UserRegistered _ -> ηι
  UserUnregistered _ -> ηι
  ArticleFeaturedOnFrontPage _ -> ηι
  ArticleQuoted _ -> ηι
  NewsTopicAdded _ -> ηι
  NewsTopicRemoved _ -> ηι
  ArticleAddedToNewsRelatedWhitelist _ -> ηι
  ArticleRemovedFromNewsRelatedWhitelist _ -> ηι
  ArticleAddedToNewsRelatedBlacklist _ -> ηι
  ArticleRemovedFromNewsRelatedBlacklist _ -> ηι
  NewsletterScheduled _ -> ηι
  MagazineCustomSectionAdded _ -> ηι
  UserDonated _ -> ηι

---- Listeners

onArticleDiscarded :: ∀ fx. ArticleDiscarded.Payload -> Run (LIST_MOST_READ_ARTICLES_PROJECTION_WRITE_OPS fx) Ɩ
onArticleDiscarded { article } = delete $ ArticleKey { id: Just article, slug: Nothing }

onArticleWritten :: ∀ fx. Instant -> ArticleWritten.Payload -> Run (LIST_MOST_READ_ARTICLES_PROJECTION_WRITE_OPS fx) Ɩ
onArticleWritten
  at
  { id
  , legacyId
  , title
  , lead
  , notes
  , sources
  , content
  , theme
  , books
  , author
  , illustrations
  , slug
  } = do
  let bookIds = books
  fetchedBooks <- Array.catMaybes <$> traverse (get ◁ BookKey) bookIds

  let
    bookMap = Map.fromFoldable (fetchedBooks <#> \(Book b) -> Tuple b.id b)

    authorIdsToFetch = Array.concat (fetchedBooks <#> \(Book b) -> b.authors)
    editorIdsToFetch = Array.catMaybes (fetchedBooks <#> \(Book b) -> b.editor)

  fetchedAuthors <- Array.catMaybes <$> traverse (get ◁ AuthorKey) authorIdsToFetch
  fetchedEditors <- Array.catMaybes <$> traverse (get ◁ EditorKey) editorIdsToFetch
  let
    authorMap = Map.fromFoldable (fetchedAuthors <#> \(Author au) -> Tuple au.id au)
    editorMap = Map.fromFoldable (fetchedEditors <#> \(Editor e) -> Tuple e.id e)

    booksData = Array.catMaybes $ bookIds <#> \bookId -> do
      b <- Map.lookup bookId bookMap
      let
        authorList = Array.catMaybes
          ( b.authors <#> \aId -> do
              au <- Map.lookup aId authorMap
              η { id: au.id, name: au.name }
          )
        editorM = b.editor >>= \eId -> Map.lookup eId editorMap <#> _.name
      η { id: b.id, name: b.name, year: b.year, cover: b.cover, authors: authorList, editor: editorM }

  mAuthor <- author ?? (get ◁ AuthorKey) ↔ η Nothing

  add $ Article
    { id
    , legacyId
    , title
    , lead
    , notes
    , sources
    , content
    , theme
    , books: Books.make booksData
    , author: mAuthor <#> \(Author { id: id_, name, biography, portrait }) -> { id: id_, name, biography, portrait }
    , illustrations: Illustrations.make illustrations
    , slug
    , writtenAt: at
    , readCount: 0
    }

onAuthorReferenced :: ∀ fx. AuthorReferenced.Payload -> Run (LIST_MOST_READ_ARTICLES_PROJECTION_WRITE_OPS fx) Ɩ
onAuthorReferenced { id, name, biography, portrait } = add $ Author { id, name, biography, portrait }

onEditorReferenced :: ∀ fx. EditorReferenced.Payload -> Run (LIST_MOST_READ_ARTICLES_PROJECTION_WRITE_OPS fx) Ɩ
onEditorReferenced { id, name } = add $ Editor { id, name }

onBookReferenced :: ∀ fx. BookReferenced.Payload -> Run (LIST_MOST_READ_ARTICLES_PROJECTION_WRITE_OPS fx) Ɩ
onBookReferenced { id, name, year, cover, authors, editor } = add $ Book { id, name, year, cover, authors, editor }

onArticleRead :: ∀ fx. ArticleRead.Payload -> Run (LIST_MOST_READ_ARTICLES_PROJECTION_WRITE_OPS fx) Ɩ
onArticleRead { id } =
  patch (ArticleKey { id: Just id, slug: Nothing }) (unwrap ▷ (\a -> a { readCount = a.readCount + 1 }) ▷ wrap)


