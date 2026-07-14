module Core.Feat.Review.Message.Query.GetArticleQuote.Projection.Projection where

import Yoga.JSON.Generics (genericWriteForeignTaggedSum, genericReadForeignTaggedSum)
import Yoga.JSON.Generics.TaggedSumRep (defaultOptions)
import Proem hiding (add)
import Control.Monad.Except as Control.Monad.Except

import Core.Mod.Projection.Finder.Filter as Base
import Core.Event.ArticleQuoted.Payload as ArticleQuoted
import Core.Event.Event (Event(..), LoadedEvent)
import Core.Exception.Exception (inj)
import Core.Mod.Article.Id.Id (ArticleId)
import Core.Mod.Article.Projection.Exception.InvalidArticleFilter (InvalidArticleFilter(..), InvalidArticleFilterRow)
import Core.Mod.Projection.Finder.Expectation.Expectation (Expectation(..))
import Core.Mod.Projection.Finder.Filter (Limit(..), StrictlyEquals(..), by, compile, class IsFilter)
import Core.Mod.Projection.Finder.Finder (Find, findMany_)
import Core.Mod.Projection.Finder.Sort as Sort
import Core.Mod.Projection.Pair (class IsPair, class ToAliasedPrimary)
import Core.Mod.Projection.Projection (class IsProjection, ProjectionWriteOps, add, coerce, delete, get)
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
import Data.Newtype (class Newtype)
import Data.Show.Generic (genericShow)
import Data.Traversable (traverse)
import Data.Tuple (Tuple(..))
import Run (Run)
import Type.Row (type (+))
import Util.Type.Random (class Random, random)
import Util.Type.String.ToString (toString)
import Core.Event.ArticleDiscarded.Payload as ArticleDiscarded
import Core.Event.ArticleWritten.Payload as ArticleWritten
import Core.Event.AuthorReferenced.Payload as AuthorReferenced
import Core.Event.BookReferenced.Payload as BookReferenced
import Core.Event.EditorReferenced.Payload as EditorReferenced
import Core.Mod.Article.Content.Content (Content)
import Core.Mod.Article.Projection.Illustrations (Illustrations)
import Core.Mod.Article.Projection.Illustrations as Illustrations
import Core.Mod.Article.Lead.Lead (Lead)
import Core.Mod.Article.Projection.Books.Books (Books)
import Core.Mod.Article.Projection.Books.Books as Books
import Core.Mod.Article.Slug.Slug (Slug)
import Core.Mod.Article.Title.Title (Title)
import Core.Mod.Author.Id.Id (AuthorId)
import Core.Mod.Author.Name.Name (Name)
import Core.Mod.Book.Id.Id (BookId)
import Core.Mod.Book.Year.Year (Year)
import Core.Mod.Editor.Id.Id (EditorId)
import Core.Mod.Editor.Name.Name as EditorName
import Core.Mod.Image.Image (Image)
import Core.Mod.Article.Theme.Theme (Theme)
import Core.Mod.Author.Biography.Biography (Biography)

data GetArticleQuoteProjection

instance
  IsProjection
    GetArticleQuoteProjection
    "getArticleQuote"
    "getArticleQuoteProjectionWriteOps"
    (GET_ARTICLE_QUOTE_PROJECTION_WRITE_OPS ())
    "getArticleQuoteProjectionReadSyncProject"
    { quote :: Quote
    }
    { quote :: QuoteIndexNeeds
    }
    { quote :: Record QuoteSortRow
    }
  where
  play = coerce @(GET_ARTICLE_QUOTE_PROJECTION_WRITE_OPS ()) play

  indexNeeds =
    { quote:
        { at: rawIndexOnly
        , article:
            { id: rawIndexOnly
            , theme: rawIndexOnly
            }
        }
    }

type GET_ARTICLE_QUOTE_PROJECTION_WRITE_OPS fx = (getArticleQuoteProjectionWriteOps :: ProjectionWriteOps | fx)
type GET_ARTICLE_QUOTE_PROJECTION_READ_SYNC_PROJECT fx = (getArticleQuoteProjectionReadSyncProject :: SyncProject | fx)

type GET_ARTICLE_QUOTE_PROJECTION_READ_FIND fx =
  GET_ARTICLE_QUOTE_QUOTE_PROJECTION_READ_FIND
    + fx

-- Model 

---- Quote

instance IsPair QuoteKey Quote QuoteRecord QuoteIndexNeeds QuoteSortRow "quote" "quotes" "getArticleQuoteQuoteProjectionReadFind" GetArticleQuoteProjection where
  toKey (Quote q) = QuoteKey q.article.id
  single = false

newtype Quote = Quote QuoteRecord

type QuoteRecord =
  { article :: ArticleRecord
  , quote :: String
  , at :: Instant
  }

type QuoteIndexNeeds =
  { at :: RawIndexOnly Instant
  , article :: { id :: RawIndexOnly ArticleId, theme :: RawIndexOnly (Maybe Theme) }
  }

derive instance Eq Quote
derive instance Ord Quote
derive newtype instance WriteForeign Quote
derive newtype instance ReadForeign Quote
derive instance Generic Quote _
derive instance Newtype Quote _

newtype QuoteKey = QuoteKey ArticleId

derive instance Eq QuoteKey
derive instance Ord QuoteKey
derive newtype instance WriteForeign QuoteKey
derive newtype instance ReadForeign QuoteKey
derive instance Generic QuoteKey _
derive instance Newtype QuoteKey _

instance ToAliasedPrimary QuoteKey where
  toAliasedPrimary (QuoteKey id) = { primary: toString id, aliases: [] }

type QuoteSortRow =
  ( at :: Ɩ
  )

---- Article 

instance IsPair ArticleKey Article ArticleRecord ArticleIndexNeeds () "article" "articles" "getArticleQuoteArticleProjectionReadFind" GetArticleQuoteProjection where
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
  , title :: Title
  , lead :: Lead
  , content :: Content
  , theme :: Maybe Theme
  , books :: Books
  , author :: Maybe ArticleAuthor
  , illustrations :: Illustrations
  , slug :: Slug
  }

type ArticleIndexNeeds = {}

derive instance Newtype Article _
derive instance Generic Article _
derive instance Eq Article
derive instance Ord Article
derive newtype instance ReadForeign Article
derive newtype instance WriteForeign Article

instance Show Article where
  show = genericShow

instance Random Article where
  random = do
    id <- random
    title <- random
    lead <- random
    content <- random
    theme <- random
    books <- random
    author <- random
    illustrations <- random
    slug <- random
    η $ Article
      { id
      , title
      , lead
      , content
      , theme
      , books
      , author
      , illustrations
      , slug
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

instance IsPair AuthorKey Author AuthorRecord AuthorIndexNeeds () "author" "authors" "getArticleQuoteAuthorProjectionReadFind" GetArticleQuoteProjection where
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

instance IsPair EditorKey Editor EditorRecord EditorIndexNeeds () "editor" "editors" "getArticleQuoteEditorProjectionReadFind" GetArticleQuoteProjection where
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

instance IsPair BookKey Book BookRecord BookIndexNeeds () "book" "books" "getArticleQuoteBookProjectionReadFind" GetArticleQuoteProjection where
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

---- Filter 

data QuoteFilter
  = QuoteArticleHasId ArticleId
  | QuoteArticleHasTheme Theme
  | QuoteAnd { left :: QuoteFilter, right :: QuoteFilter }
  | QuoteOr { left :: QuoteFilter, right :: QuoteFilter }
  | QuoteNot QuoteFilter
  | QuoteTrue
  | QuoteFalse

derive instance Eq QuoteFilter
derive instance Ord QuoteFilter
derive instance Generic QuoteFilter _

instance WriteForeign QuoteFilter where
  writeImpl filter = (genericWriteForeignTaggedSum defaultOptions) filter

instance ReadForeign QuoteFilter where
  readImpl json = (genericReadForeignTaggedSum defaultOptions) json

instance Show QuoteFilter where
  show filter = genericShow filter

instance HeytingAlgebra QuoteFilter where
  ff = QuoteFalse
  tt = QuoteTrue
  not = QuoteNot
  implies a b = (QuoteNot a) || b
  conj left right = QuoteAnd { left, right }
  disj left right = QuoteOr { left, right }

instance IsFilter QuoteFilter Quote where
  compile _ (QuoteArticleHasId articleId) = by @"article.id" StrictlyEquals articleId
  compile _ (QuoteArticleHasTheme theme) = by @"article.theme" StrictlyEquals (Just theme)

  compile e (QuoteAnd { left: f1, right: f2 }) =
    (compile e f1)
      && (compile e f2)

  compile e (QuoteOr { left: f1, right: f2 }) =
    (compile e f1)
      || (compile e f2)

  compile e (QuoteNot f) = not (compile e f)

  compile _ QuoteTrue = Base.True
  compile _ QuoteFalse = Base.False

instance IsRefinedType QuoteFilter (InvalidArticleFilterRow ()) where
  makeFromJson _ json = case Control.Monad.Except.runExcept (readImpl json) of
    Left _ -> Left $ inj InvalidArticleFilter
    Right filter -> η filter

instance Random QuoteFilter where
  random = QuoteArticleHasId <$> random

---- Find 

type GET_ARTICLE_QUOTE_QUOTE_PROJECTION_READ_FIND fx = (getArticleQuoteQuoteProjectionReadFind :: Find Quote | fx)
type GET_ARTICLE_QUOTE_QUOTE_PROJECTION_READ fx =
  GET_ARTICLE_QUOTE_QUOTE_PROJECTION_READ_FIND
    + GET_ARTICLE_QUOTE_PROJECTION_READ_SYNC_PROJECT
    + fx

-- | Finds the most recent quote. 
-- | If `mTheme` is `Nothing`, this fetches the absolute most recent quote across all articles (no theme filtering).
-- | If `mTheme` is `Just theme`, this filters out any articles that do not have this exact theme.
findMostRecentQuote
  :: ∀ fx
   . Maybe Theme
  -> Run (GET_ARTICLE_QUOTE_QUOTE_PROJECTION_READ + fx) (Maybe Quote)
findMostRecentQuote mTheme = do
  page <- findMany_
    { filter: QuoteArticleHasTheme <$> mTheme
    , limit: Finite 1
    , sort: [ Sort.by @"at" Sort.Desc ]
    , after: Nothing
    , expectation: QuickNothingBetterThanSlowerSomething
    }

  η $ Array.head page.items

-- Play 

play :: ∀ fx. LoadedEvent -> Run (GET_ARTICLE_QUOTE_PROJECTION_WRITE_OPS fx) Ɩ
play { event, at } = case event of
  ArticleQuoted payload -> onArticleQuoted at payload
  ArticleDiscarded payload -> onArticleDiscarded payload
  ArticleWritten payload -> onArticleWritten payload
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
  ArticleFeaturedOnFrontPage _ -> ηι
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

onArticleQuoted :: ∀ fx. Instant -> ArticleQuoted.Payload -> Run (GET_ARTICLE_QUOTE_PROJECTION_WRITE_OPS fx) Ɩ
onArticleQuoted at { article, quote } = do
  mArticle <- get (ArticleKey { id: Just article, slug: Nothing })
  case mArticle of
    Nothing -> ηι
    Just (Article aRecord) -> do
      add $ Quote
        { article: aRecord
        , quote
        , at
        }

onArticleDiscarded :: ∀ fx. ArticleDiscarded.Payload -> Run (GET_ARTICLE_QUOTE_PROJECTION_WRITE_OPS fx) Ɩ
onArticleDiscarded { article } = do
  delete $ ArticleKey { id: Just article, slug: Nothing }
  delete $ QuoteKey article

onArticleWritten :: ∀ fx. ArticleWritten.Payload -> Run (GET_ARTICLE_QUOTE_PROJECTION_WRITE_OPS fx) Ɩ
onArticleWritten
  { id
  , title
  , lead
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

  let
    aRecord =
      { id
      , title
      , lead
      , content
      , theme
      , books: Books.make booksData
      , author: mAuthor <#> \(Author { id: id_, name, biography, portrait }) -> { id: id_, name, biography, portrait }
      , illustrations: Illustrations.make illustrations
      , slug
      }

  add $ Article aRecord

  -- Update Quote if it exists
  mQuote <- get (QuoteKey id)
  case mQuote of
    Nothing -> ηι
    Just (Quote qRecord) ->
      add $ Quote qRecord { article = aRecord }

onAuthorReferenced :: ∀ fx. AuthorReferenced.Payload -> Run (GET_ARTICLE_QUOTE_PROJECTION_WRITE_OPS fx) Ɩ
onAuthorReferenced { id, name, biography, portrait } = add $ Author { id, name, biography, portrait }

onEditorReferenced :: ∀ fx. EditorReferenced.Payload -> Run (GET_ARTICLE_QUOTE_PROJECTION_WRITE_OPS fx) Ɩ
onEditorReferenced { id, name } = add $ Editor { id, name }

onBookReferenced :: ∀ fx. BookReferenced.Payload -> Run (GET_ARTICLE_QUOTE_PROJECTION_WRITE_OPS fx) Ɩ
onBookReferenced { id, name, year, cover, authors, editor } = add $ Book { id, name, year, cover, authors, editor }


