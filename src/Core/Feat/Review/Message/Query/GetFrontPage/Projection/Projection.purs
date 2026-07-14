module Core.Feat.Review.Message.Query.GetFrontPage.Projection.Projection where

import Yoga.JSON.Generics (genericWriteForeignTaggedSum, genericReadForeignTaggedSum)
import Yoga.JSON.Generics.TaggedSumRep (defaultOptions)
import Foreign as Foreign
import Proem hiding (add)
import Data.Bifunctor (lmap)
import Control.Monad.Except as Control.Monad.Except

import Core.Mod.Author.Biography.Biography (Biography)
import Core.Event.ArticleDiscarded.Payload as ArticleDiscarded
import Core.Event.ArticleFeaturedOnFrontPage.Payload as ArticleFeaturedOnFrontPage
import Core.Event.ArticleWritten.Payload as ArticleWritten
import Core.Event.AuthorReferenced.Payload as AuthorReferenced
import Core.Event.BookReferenced.Payload as BookReferenced
import Core.Event.EditorReferenced.Payload as EditorReferenced
import Core.Event.Event (Event(..), LoadedEvent)
import Core.Exception.Exception (inj)
import Core.Mod.Article.Content.Content (Content)
import Core.Mod.Article.FrontPage.Position.Position (Position(..))
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
import Core.Mod.Projection.Finder.Filter (StrictlyEquals(..), StrictlyNotEquals(..), by, class IsFilter, compile)
import Core.Mod.Projection.Finder.Filter as Base
import Core.Mod.Projection.Finder.Finder (Find, FindOpt, Page, findManyByKeys, findMany_, findOneBy, findOneByKey)
import Core.Mod.Projection.Finder.Sort (SortCriteria)
import Core.Mod.Projection.Pair (class IsPair, class ToAliasedPrimary, persistenceKeyFromKey)
import Core.Mod.Projection.Projection (ProjectionWriteOps, add, class IsProjection, coerce, delete, get, patch, put)
import Core.Mod.Projection.SearchIndex (RawIndexOnly, rawIndexOnly)
import Core.Mod.Projection.SyncProject (SyncProject)
import Core.Mod.Time.Instant (Instant)
import Core.Util.Validation (class IsRefinedType)
import Yoga.JSON (class ReadForeign, class WriteForeign, readImpl, writeImpl)
import Data.Array as Array
import Data.Either (Either(..), note)
import Data.Foldable (for_)
import Data.Generic.Rep (class Generic)
import Data.Map as Map
import Data.Maybe (Maybe(..), maybe)
import Data.Newtype (class Newtype, unwrap, wrap)
import Data.Set (Set)
import Data.Set as Set
import Data.Show.Generic (genericShow)
import Data.String as String
import Data.Traversable (traverse)
import Data.Tuple (Tuple(..))
import Run (Run)
import Type.Row (type (+))
import Util.Type.Random (class Random, random)
import Util.Type.String.ToString (class FromString, fromString, toString)

data GetFrontPageProjection

instance
  IsProjection
    GetFrontPageProjection
    "getFrontPage"
    "getFrontPageProjectionWriteOps"
    (GET_FRONT_PAGE_PROJECTION_WRITE_OPS ())
    "getFrontPageProjectionReadSyncProject"
    { article :: Article
    , frontPage :: FrontPage
    }
    { article :: ArticleIndexNeeds
    , frontPage :: FrontPageIndexNeeds
    }
    { article :: Record ArticleSortRow
    , frontPage :: Record ()
    }
  where

  indexNeeds =
    { article:
        { id: rawIndexOnly
        , legacyId: rawIndexOnly
        , theme: rawIndexOnly
        , books:
            { ids: rawIndexOnly
            , hasAtLeastOneCover: rawIndexOnly
            }
        , writtenAt: rawIndexOnly
        , illustrations:
            { hasAtLeastOneLandscape: rawIndexOnly
            , hasAtLeastOne: rawIndexOnly
            }
        }
    , frontPage: {}
    }

  play = coerce @(GET_FRONT_PAGE_PROJECTION_WRITE_OPS ()) play

type GET_FRONT_PAGE_PROJECTION_WRITE_OPS fx = (getFrontPageProjectionWriteOps :: ProjectionWriteOps | fx)
type GET_FRONT_PAGE_PROJECTION_READ_SYNC_PROJECT fx = (getFrontPageProjectionReadSyncProject :: SyncProject | fx)
type GET_FRONT_PAGE_PROJECTION_READ_FIND fx =
  GET_FRONT_PAGE_ARTICLE_PROJECTION_READ_FIND
    + GET_FRONT_PAGE_FRONT_PAGE_PROJECTION_READ_FIND
    + fx

-- Model 

---- Article 

instance IsPair ArticleKey Article ArticleRecord ArticleIndexNeeds ArticleSortRow "article" "articles" "getFrontPageArticleProjectionReadFind" GetFrontPageProjection where
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
  , onFrontPages :: Set FrontPageKey
  , illustrations :: Illustrations
  , slug :: Slug
  , writtenAt :: Instant
  }

type ArticleIndexNeeds =
  { id :: RawIndexOnly ArticleId
  , legacyId :: RawIndexOnly (Maybe Int)
  , theme :: RawIndexOnly (Maybe Theme)
  , books ::
      { ids :: RawIndexOnly (Array BookId)
      , hasAtLeastOneCover :: RawIndexOnly Boolean
      }
  , writtenAt :: RawIndexOnly Instant
  , illustrations ::
      { hasAtLeastOneLandscape :: RawIndexOnly Boolean
      , hasAtLeastOne :: RawIndexOnly Boolean
      }
  }

derive instance Newtype Article _
derive instance Generic Article _
derive instance Eq Article
derive instance Ord Article

instance ReadForeign Article where
  readImpl f = do
    r <- readImpl f
    pure (Article (r { onFrontPages = Set.fromFoldable (r.onFrontPages :: Array FrontPageKey) }))


instance WriteForeign Article where
  writeImpl (Article r) = writeImpl (r { onFrontPages = Array.fromFoldable r.onFrontPages })


instance Show Article where
  show = genericShow

type ArticleSortRow =
  ( id :: Ɩ
  , writtenAt :: Ɩ
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
      , onFrontPages: Set.empty
      , illustrations
      , slug
      , writtenAt
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

---- FrontPage 

instance IsPair FrontPageKey FrontPage FrontPageRecord FrontPageIndexNeeds () "frontPage" "frontPages" "getFrontPageFrontPageProjectionReadFind" GetFrontPageProjection where
  toKey (FrontPage { theme }) = FrontPageKey theme

  single = false

newtype FrontPage = FrontPage FrontPageRecord

type FrontPageArticles =
  { topLeft :: Maybe ArticleId
  , topRight :: Maybe ArticleId
  , center :: Maybe ArticleId
  , bottomLeft :: Maybe ArticleId
  , bottomRight :: Maybe ArticleId
  }

emptyFrontPage :: FrontPage
emptyFrontPage = FrontPage
  { theme: Nothing
  , articles:
      { topLeft: Nothing
      , topRight: Nothing
      , center: Nothing
      , bottomLeft: Nothing
      , bottomRight: Nothing
      }
  }

type FrontPageRecord =
  { theme :: Maybe Theme
  , articles :: FrontPageArticles
  }

type FrontPageIndexNeeds = {}

derive instance Newtype FrontPage _
derive instance Generic FrontPage _
derive instance Eq FrontPage
derive instance Ord FrontPage
derive newtype instance ReadForeign FrontPage
derive newtype instance WriteForeign FrontPage
derive newtype instance Random FrontPage

instance Show FrontPage where
  show = genericShow

newtype FrontPageKey = FrontPageKey (Maybe Theme)

derive newtype instance Eq FrontPageKey
derive newtype instance Ord FrontPageKey
derive newtype instance Random FrontPageKey
derive instance Generic FrontPageKey _

instance Show FrontPageKey where
  show = genericShow

instance ToAliasedPrimary FrontPageKey where
  toAliasedPrimary (FrontPageKey Nothing) = { primary: "main", aliases: [] }
  toAliasedPrimary (FrontPageKey (Just themeId)) = { primary: "theme:" <> toString themeId, aliases: [] }

instance FromString FrontPageKey where
  fromString "main" = Just (FrontPageKey Nothing)
  fromString str = case String.stripPrefix (String.Pattern "theme:") str of
    Just tIdStr -> (FrontPageKey ◁ Just) <$> fromString tIdStr
    Nothing -> Nothing

instance WriteForeign FrontPageKey where
  writeImpl (FrontPageKey Nothing) = writeImpl "main"
  writeImpl (FrontPageKey (Just themeId)) = writeImpl ("theme:" <> toString themeId)

instance ReadForeign FrontPageKey where
  readImpl json = do
    str <- readImpl json
    Control.Monad.Except.except $ lmap pure $ note (Foreign.ForeignError "UnexpectedValue") (fromString str)

---- Author 

instance IsPair AuthorKey Author AuthorRecord AuthorIndexNeeds () "author" "authors" "getFrontPageAuthorProjectionReadFind" GetFrontPageProjection where
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

instance IsPair EditorKey Editor EditorRecord EditorIndexNeeds () "editor" "editors" "getFrontPageEditorProjectionReadFind" GetFrontPageProjection where
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

instance IsPair BookKey Book BookRecord BookIndexNeeds () "book" "books" "getFrontPageBookProjectionReadFind" GetFrontPageProjection where
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
  | ArticleIsAboutAtLeastOneBook
  | ArticleIsAboutAtLeastOneBookWithCover
  | ArticleHasAtLeastOneIllustration BookCoverFallbackIncluded
  | ArticleHasAtLeastOneLandscapeIllustration
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

  compile _ ArticleIsAboutAtLeastOneBook = by @"books.ids" StrictlyNotEquals []
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

  compile _ ArticleHasAtLeastOneLandscapeIllustration =
    by @"illustrations.hasAtLeastOneLandscape" StrictlyEquals true

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

type GET_FRONT_PAGE_ARTICLE_PROJECTION_READ_FIND fx = (getFrontPageArticleProjectionReadFind :: Find Article | fx)
type GET_FRONT_PAGE_ARTICLE_PROJECTION_READ fx =
  GET_FRONT_PAGE_ARTICLE_PROJECTION_READ_FIND
    + GET_FRONT_PAGE_PROJECTION_READ_SYNC_PROJECT
    + fx

findArticleById :: ∀ fx. ArticleId -> Run (GET_FRONT_PAGE_ARTICLE_PROJECTION_READ + fx) (Maybe Article)
findArticleById id = findOneByKey (ArticleKey { id: Just id, slug: Nothing })

findArticlesByIds :: ∀ fx. Array ArticleId -> Run (GET_FRONT_PAGE_ARTICLE_PROJECTION_READ + fx) (Array Article)
findArticlesByIds ids = findManyByKeys (ids <#> \id -> ArticleKey { id: Just id, slug: Nothing })

findArticleByLegacyId :: ∀ fx. Int -> Run (GET_FRONT_PAGE_ARTICLE_PROJECTION_READ + fx) (Maybe Article)
findArticleByLegacyId legacyId = findOneBy @Article @"legacyId" StrictlyEquals (Just legacyId)

findArticles
  :: ∀ fx
   . FindOpt ArticleFilter ArticleId Article
  -> Run (GET_FRONT_PAGE_ARTICLE_PROJECTION_READ + fx) (Page Article)
findArticles opt = findMany_ opt { after = opt.after <#> (\id -> ArticleKey { id: Just id, slug: Nothing }) ▷ persistenceKeyFromKey }

type GET_FRONT_PAGE_FRONT_PAGE_PROJECTION_READ_FIND fx = (getFrontPageFrontPageProjectionReadFind :: Find FrontPage | fx)
type GET_FRONT_PAGE_FRONT_PAGE_PROJECTION_READ fx =
  GET_FRONT_PAGE_FRONT_PAGE_PROJECTION_READ_FIND
    + GET_FRONT_PAGE_PROJECTION_READ_SYNC_PROJECT
    + fx

findFrontPage :: ∀ fx. Maybe Theme -> Run (GET_FRONT_PAGE_FRONT_PAGE_PROJECTION_READ + fx) (Maybe FrontPage)
findFrontPage theme = findOneByKey (FrontPageKey theme)

-- Play 

play :: ∀ fx. LoadedEvent -> Run (GET_FRONT_PAGE_PROJECTION_WRITE_OPS fx) Ɩ
play { event, at } = case event of
  ArticleDiscarded payload -> onArticleDiscarded payload
  ArticleFeaturedOnFrontPage payload -> onArticleFeaturedOnFrontPage payload
  ArticleWritten payload -> onArticleWritten at payload
  AuthorReferenced payload -> onAuthorReferenced payload
  EditorReferenced payload -> onEditorReferenced payload
  BookReferenced payload -> onBookReferenced payload
  AuthorDereferenced _ -> ηι
  BookDereferenced _ -> ηι
  MagazineIssueReferenced _ -> ηι
  MagazineIssueDereferenced _ -> ηι
  EditorDereferenced _ -> ηι
  UserEmailChanged _ -> ηι
  UserRegistered _ -> ηι
  UserUnregistered _ -> ηι
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

onArticleDiscarded :: ∀ fx. ArticleDiscarded.Payload -> Run (GET_FRONT_PAGE_PROJECTION_WRITE_OPS fx) Ɩ
onArticleDiscarded { article } = do
  mArticle <- get (ArticleKey { id: Just article, slug: Nothing })

  case mArticle of
    Nothing -> ηι
    Just (Article { onFrontPages }) -> do
      for_ (Array.fromFoldable onFrontPages) \key -> do
        mFp <- get key

        case mFp of
          Nothing -> ηι
          Just (FrontPage fp) ->
            let
              r = fp.articles
              set =
                (r.topLeft == Just article ? _ { topLeft = Nothing } ↔ identity)
                  ▷ (r.topRight == Just article ? _ { topRight = Nothing } ↔ identity)
                  ▷ (r.center == Just article ? _ { center = Nothing } ↔ identity)
                  ▷ (r.bottomLeft == Just article ? _ { bottomLeft = Nothing } ↔ identity)
                  ▷ (r.bottomRight == Just article ? _ { bottomRight = Nothing } ↔ identity)
            in
              put $ FrontPage (fp { articles = set r })

  delete $ ArticleKey { id: Just article, slug: Nothing }

onArticleFeaturedOnFrontPage :: ∀ fx. ArticleFeaturedOnFrontPage.Payload -> Run (GET_FRONT_PAGE_PROJECTION_WRITE_OPS fx) Ɩ
onArticleFeaturedOnFrontPage { article, position, theme } = do
  let fpKey = FrontPageKey theme

  mFp <- get fpKey

  let
    FrontPage fp = case mFp of
      Nothing -> FrontPage { theme, articles: (unwrap emptyFrontPage).articles }
      Just f -> f

    oldArticle = case position of
      TopLeft -> fp.articles.topLeft
      TopRight -> fp.articles.topRight
      Center -> fp.articles.center
      BottomLeft -> fp.articles.bottomLeft
      BottomRight -> fp.articles.bottomRight

    updatedArticles = case position of
      TopLeft -> fp.articles { topLeft = Just article }
      TopRight -> fp.articles { topRight = Just article }
      Center -> fp.articles { center = Just article }
      BottomLeft -> fp.articles { bottomLeft = Just article }
      BottomRight -> fp.articles { bottomRight = Just article }

  put $ FrontPage (fp { articles = updatedArticles })

  case oldArticle of
    Just rId -> patch (ArticleKey { id: Just rId, slug: Nothing }) (unwrap ▷ (\r -> r { onFrontPages = Set.delete fpKey r.onFrontPages }) ▷ wrap)
    Nothing -> ηι

  patch (ArticleKey { id: Just article, slug: Nothing }) (unwrap ▷ (\r -> r { onFrontPages = Set.insert fpKey r.onFrontPages }) ▷ wrap)

onArticleWritten :: ∀ fx. Instant -> ArticleWritten.Payload -> Run (GET_FRONT_PAGE_PROJECTION_WRITE_OPS fx) Ɩ
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
    , onFrontPages: Set.empty
    , illustrations: Illustrations.make illustrations
    , slug
    , writtenAt: at
    }

onAuthorReferenced :: ∀ fx. AuthorReferenced.Payload -> Run (GET_FRONT_PAGE_PROJECTION_WRITE_OPS fx) Ɩ
onAuthorReferenced { id, name, biography, portrait } = add $ Author { id, name, biography, portrait }

onEditorReferenced :: ∀ fx. EditorReferenced.Payload -> Run (GET_FRONT_PAGE_PROJECTION_WRITE_OPS fx) Ɩ
onEditorReferenced { id, name } = add $ Editor { id, name }

onBookReferenced :: ∀ fx. BookReferenced.Payload -> Run (GET_FRONT_PAGE_PROJECTION_WRITE_OPS fx) Ɩ
onBookReferenced { id, name, year, cover, authors, editor } = add $ Book { id, name, year, cover, authors, editor }




