module Core.Feat.Review.Message.Query.GetArticle.Projection.Projection where

import Yoga.JSON.Generics (genericWriteForeignTaggedSum, genericReadForeignTaggedSum)
import Yoga.JSON.Generics.TaggedSumRep (defaultOptions)
import Foreign as Foreign
import Proem hiding (add)
import Control.Monad.Except as Control.Monad.Except

import Core.Event.ArticleAddedToNewsRelatedBlacklist.Payload as ArticleAddedToNewsRelatedBlacklist
import Core.Event.ArticleAddedToNewsRelatedWhitelist.Payload as ArticleAddedToNewsRelatedWhitelist
import Core.Event.ArticleDiscarded.Payload as ArticleDiscarded
import Core.Event.ArticleRemovedFromNewsRelatedBlacklist.Payload as ArticleRemovedFromNewsRelatedBlacklist
import Core.Event.ArticleRemovedFromNewsRelatedWhitelist.Payload as ArticleRemovedFromNewsRelatedWhitelist
import Core.Event.ArticleWritten.Payload as ArticleWritten
import Core.Event.AuthorReferenced.Payload as AuthorReferenced
import Core.Event.BookReferenced.Payload as BookReferenced
import Core.Event.EditorReferenced.Payload as EditorReferenced
import Core.Event.Event (Event(..), LoadedEvent)
import Core.Event.MagazineIssueReferenced.Payload as MagazineIssueReferenced
import Core.Event.NewsTopicAdded.Payload as NewsTopicAdded
import Core.Event.NewsTopicRemoved.Payload as NewsTopicRemoved
import Core.Exception.Exception (inj)
import Core.Mod.Article.Content.Content (Content)
import Core.Mod.Article.Id.Id (ArticleId)
import Core.Mod.Article.Lead.Lead (Lead)
import Core.Mod.Article.MagazineIssue.MagazineIssue as BaseMagazineIssue
import Core.Mod.Article.Notes.Notes (Notes)
import Core.Mod.Article.PageNumber.PageNumber (PageNumber)
import Core.Mod.Article.Projection.Books.Books (Books, fromBooksDto, BooksDto)
import Core.Mod.Article.Projection.Books.Books as Books
import Core.Mod.Article.Projection.Exception.InvalidArticleFilter (InvalidArticleFilter(..), InvalidArticleFilterRow)
import Core.Mod.Article.Projection.Illustrations (Illustrations, fromIllustrationsDto, IllustrationsDto)
import Core.Mod.Article.Projection.Illustrations as Illustrations
import Core.Mod.Html.Html (NonEmptyHtml)
import Core.Mod.Article.Projection.MagazineIssue as Projected
import Core.Mod.Article.Projection.WrittenAt (WrittenAt)
import Core.Mod.Article.Projection.WrittenAt as WrittenAt
import Core.Mod.Article.Slug.Slug (Slug)
import Core.Mod.Article.Sources.Sources (Sources)
import Core.Mod.Article.Theme.Theme (Theme)
import Data.Nullable (Nullable, toMaybe)
import Core.Mod.Article.Title.Title (Title)
import Core.Mod.Author.Biography.Biography (Biography)
import Core.Mod.Author.Id.Id (AuthorId)
import Core.Mod.Author.Name.Name (Name)
import Core.Mod.Book.Id.Id (BookId)
import Core.Mod.Book.Year.Year (Year)
import Core.Mod.Editor.Id.Id (EditorId)
import Core.Mod.Editor.Name.Name as EditorName
import Core.Mod.Image.Image (Image)
import Core.Mod.MagazineIssue.Id.Id (MagazineIssueId)
import Core.Mod.MagazineIssue.Section.Section (SectionF(..))
import Core.Mod.MagazineIssue.CustomSection.Id.Id as CustomSectionId
import Core.Mod.MagazineIssue.CustomSection.Name.Name as CustomSectionName
import Core.Event.MagazineCustomSectionAdded.Payload as MagazineCustomSectionAdded
import Core.Mod.MagazineIssue.Slug.Slug as MagazineIssueSlug
import Core.Mod.NewsTopic.Id.Id (NewsTopicId)
import Core.Mod.NewsTopic.SearchInput.SearchInput as NewsTopicTitle
import Core.Mod.Projection.Finder.Filter (class IsFilter, EqualsUpToNormalization(..), InnerWeightA, InnerWeightB, InnerWeightC, InnerWeightD, Matches(..), StrictlyEquals(..), StrictlyNotEquals(..), Weight, by, byExists, byMatches, compile, Contains(..))
import Core.Mod.Projection.Finder.Filter as Base
import Core.Mod.Projection.Finder.Finder (Find, findOneBy, findOneByKey)
import Core.Mod.Projection.Finder.Sort (SortCriteria)
import Core.Mod.Projection.Pair (class IsPair, class ToAliasedPrimary)
import Core.Mod.Projection.Projection (class IsProjection, ProjectionWriteOps, add, coerce, delete, get, patch)
import Core.Mod.Projection.SearchIndex (EveryTextIndexesWithWeightA, EveryTextIndexesWithWeightB, FullTextIndexOnlyB, FullTextIndexOnlyD, RawIndexOnly, EveryTextIndexesWithWeightC, everyTextIndexesWithWeightA, everyTextIndexesWithWeightB, everyTextIndexesWithWeightC, fullTextIndexOnlyWithWeightB, fullTextIndexOnlyWithWeightD, rawIndexOnly, InvertedIndexOnly, invertedIndexOnly)
import Core.Mod.Projection.SyncProject (SyncProject)
import Core.Mod.Time.Instant (Instant)
import Core.Mod.Time.Year (Year) as Time
import Core.Util.Validation (class IsRefinedType)
import Foreign (Foreign)
import Yoga.JSON (class ReadForeign, class WriteForeign, readImpl)
import Foreign.Index (readProp)
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
import Util.Type.String.ToString (fromString, toString)

data GetArticleProjection

instance
  IsProjection
    GetArticleProjection
    "getArticle"
    "getArticleProjectionWriteOps"
    (GET_ARTICLE_PROJECTION_WRITE_OPS ())
    "getArticleProjectionReadSyncProject"
    { article :: Article
    }
    { article :: ArticleIndexNeeds
    }
    { article :: Record ()
    }
  where

  indexNeeds =
    { article:
        { id: rawIndexOnly
        , legacyId: rawIndexOnly
        , title: everyTextIndexesWithWeightA
        , lead: fullTextIndexOnlyWithWeightB
        , notes: fullTextIndexOnlyWithWeightD
        , sources: fullTextIndexOnlyWithWeightD
        , content: fullTextIndexOnlyWithWeightB
        , theme: rawIndexOnly
        , author:
            { id: rawIndexOnly
            , name: everyTextIndexesWithWeightC
            }
        , books:
            { ids: rawIndexOnly
            , names: everyTextIndexesWithWeightB
            , authors:
                { ids: invertedIndexOnly
                , names: everyTextIndexesWithWeightB
                }
            , hasAtLeastOneCover: rawIndexOnly
            }
        , slug: rawIndexOnly
        , writtenAt:
            { instant: rawIndexOnly
            , year: rawIndexOnly
            }
        , illustrations:
            { hasAtLeastOneLandscape: rawIndexOnly
            , hasAtLeastOne: rawIndexOnly
            }
        , seo:
            { updatedAt: rawIndexOnly
            }
        , addedToNewsRelatedWhitelist: rawIndexOnly
        , addedToNewsRelatedBlacklist: rawIndexOnly
        , magazineIssue:
            { issue: { id: rawIndexOnly, slug: rawIndexOnly }
            , pageNumber: rawIndexOnly
            , onCover: rawIndexOnly
            }
        }
    }

  play = coerce @(GET_ARTICLE_PROJECTION_WRITE_OPS ()) play

type GET_ARTICLE_PROJECTION_WRITE_OPS fx = (getArticleProjectionWriteOps :: ProjectionWriteOps | fx)
type GET_ARTICLE_PROJECTION_READ_SYNC_PROJECT fx = (getArticleProjectionReadSyncProject :: SyncProject | fx)
type GET_ARTICLE_PROJECTION_READ_FIND fx =
  GET_ARTICLE_ARTICLE_PROJECTION_READ_FIND
    + fx

-- Model 

---- Article 

instance IsPair ArticleKey Article ArticleRecord ArticleIndexNeeds ArticleSortRow "article" "articles" "articleGetArticleProjectionReadFind" GetArticleProjection where
  toKey (Article { id, slug }) = ArticleKey { id: Just id, slug: Just slug }

  single = false

newtype Article = Article ArticleRecord

type ArticleAuthor =
  { id :: AuthorId
  , name :: Name
  , biography :: Biography
  , portrait :: Maybe Image
  }

type ArticleAuthorDto =
  { id :: AuthorId
  , name :: Name
  , biography :: Nullable NonEmptyHtml
  , portrait :: Nullable Image
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
  , profitable :: Boolean
  , slug :: Slug
  , writtenAt :: WrittenAt
  , addedToNewsRelatedWhitelist :: Boolean
  , addedToNewsRelatedBlacklist :: Boolean
  , magazineIssue :: Maybe Projected.MagazineIssue
  , seo ::
      { updatedAt :: Instant
      }
  }

type ArticleRecordDto =
  { id :: ArticleId
  , legacyId :: Nullable Int
  , title :: Title
  , lead :: Nullable NonEmptyHtml
  , notes :: Nullable NonEmptyHtml
  , sources :: Nullable NonEmptyHtml
  , content :: Content
  , theme :: Nullable String
  , books :: BooksDto
  , author :: Nullable ArticleAuthorDto
  , illustrations :: IllustrationsDto
  , profitable :: Boolean
  , slug :: Slug
  , writtenAt :: WrittenAt
  , addedToNewsRelatedWhitelist :: Boolean
  , addedToNewsRelatedBlacklist :: Boolean
  , magazineIssue :: Nullable Projected.MagazineIssue
  , seo :: { updatedAt :: Instant }
  }

foreign import unsafeDecodeArticleDto :: Foreign -> ArticleRecordDto

type ArticleIndexNeeds =
  { id :: RawIndexOnly ArticleId
  , legacyId :: RawIndexOnly (Maybe Int)
  , title :: EveryTextIndexesWithWeightA Title
  , lead :: FullTextIndexOnlyB Lead
  , notes :: FullTextIndexOnlyD Notes
  , sources :: FullTextIndexOnlyD Sources
  , content :: FullTextIndexOnlyB Content
  , theme :: RawIndexOnly (Maybe Theme)
  , author ::
      { id :: RawIndexOnly AuthorId
      , name :: EveryTextIndexesWithWeightC Name
      }
  , books ::
      { ids :: RawIndexOnly (Array BookId)
      , names :: EveryTextIndexesWithWeightB (Array Name)
      , authors ::
          { ids :: InvertedIndexOnly (Array AuthorId)
          , names :: EveryTextIndexesWithWeightB (Array Name)
          }
      , hasAtLeastOneCover :: RawIndexOnly Boolean
      }
  , slug :: RawIndexOnly Slug
  , writtenAt ::
      { instant :: RawIndexOnly Instant
      , year :: RawIndexOnly Time.Year
      }
  , illustrations ::
      { hasAtLeastOneLandscape :: RawIndexOnly Boolean
      , hasAtLeastOne :: RawIndexOnly Boolean
      }
  , addedToNewsRelatedWhitelist :: RawIndexOnly Boolean
  , addedToNewsRelatedBlacklist :: RawIndexOnly Boolean
  , magazineIssue ::
      { issue :: { id :: RawIndexOnly MagazineIssueId, slug :: RawIndexOnly MagazineIssueSlug.Slug }
      , pageNumber :: RawIndexOnly PageNumber
      , onCover :: RawIndexOnly Boolean
      }
  , seo ::
      { updatedAt :: RawIndexOnly Instant
      }
  }

defaultInnerWeightA :: InnerWeightA
defaultInnerWeightA = 1.0

defaultInnerWeightB :: InnerWeightB
defaultInnerWeightB = 0.7

defaultInnerWeightC :: InnerWeightC
defaultInnerWeightC = 0.55

defaultInnerWeightD :: InnerWeightD
defaultInnerWeightD = 0.1

derive instance Newtype Article _
derive instance Generic Article _
derive instance Eq Article
derive instance Ord Article

instance ReadForeign Article where
  readImpl json = η $ Article (fromDto (unsafeDecodeArticleDto json))

fromArticleAuthorDto :: ArticleAuthorDto -> ArticleAuthor
fromArticleAuthorDto dto =
  { id: dto.id
  , name: dto.name
  , biography: toMaybe dto.biography
  , portrait: toMaybe dto.portrait
  }

fromDto :: ArticleRecordDto -> ArticleRecord
fromDto dto =
  { id: dto.id
  , legacyId: toMaybe dto.legacyId
  , title: dto.title
  , lead: toMaybe dto.lead
  , notes: toMaybe dto.notes
  , sources: toMaybe dto.sources
  , content: dto.content
  , theme: toMaybe dto.theme >>= fromString
  , books: fromBooksDto dto.books
  , author: fromArticleAuthorDto <$> toMaybe dto.author
  , illustrations: fromIllustrationsDto dto.illustrations
  , profitable: dto.profitable
  , slug: dto.slug
  , writtenAt: dto.writtenAt
  , addedToNewsRelatedWhitelist: dto.addedToNewsRelatedWhitelist
  , addedToNewsRelatedBlacklist: dto.addedToNewsRelatedBlacklist
  , magazineIssue: toMaybe dto.magazineIssue
  , seo: dto.seo
  }

decodeArticleAuthorJson :: Foreign -> Foreign.F ArticleAuthor
decodeArticleAuthorJson json = do
  obj <- readImpl json
  id <- readProp "id" obj >>= readImpl
  name <- readProp "name" obj >>= readImpl
  biography <- readProp "biography" obj >>= readImpl
  portrait <- readProp "portrait" obj >>= readImpl
  η { id, name, biography, portrait }

derive newtype instance WriteForeign Article

instance Show Article where
  show = genericShow

type ArticleSortRow =
  ( id :: Ɩ
  , title :: Ɩ
  , "author.name" :: Ɩ
  , "writtenAt.instant" :: Ɩ
  , "writtenAt.year" :: Ɩ
  , "magazineIssue.pageNumber" :: Ɩ
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
    profitable <- random
    slug <- random
    writtenAt <- random
    addedToNewsRelatedWhitelist <- random
    addedToNewsRelatedBlacklist <- random
    magazineIssue <- random
    updatedAt <- random

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
      , profitable
      , slug
      , writtenAt
      , addedToNewsRelatedWhitelist
      , addedToNewsRelatedBlacklist
      , magazineIssue
      , seo: { updatedAt }
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

instance IsPair AuthorKey Author AuthorRecord AuthorIndexNeeds () "author" "authors" "articleAuthorProjectionReadFind" GetArticleProjection where
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

instance IsPair EditorKey Editor EditorRecord EditorIndexNeeds () "editor" "editors" "articleEditorProjectionReadFind" GetArticleProjection where
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

instance IsPair BookKey Book BookRecord BookIndexNeeds () "book" "books" "articleBookProjectionReadFind" GetArticleProjection where
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

---- NewsTopic 

instance IsPair NewsTopicKey NewsTopic NewsTopicRecord NewsTopicIndexNeeds () "newsTopic" "newsTopics" "articleNewsTopicProjectionReadFind" GetArticleProjection where
  toKey (NewsTopic { id }) = NewsTopicKey id

  single = false

newtype NewsTopic = NewsTopic NewsTopicRecord

type NewsTopicRecord =
  { id :: NewsTopicId
  , searchInput :: NewsTopicTitle.SearchInput
  }

type NewsTopicIndexNeeds =
  { id :: RawIndexOnly NewsTopicId
  , searchInput :: EveryTextIndexesWithWeightA NewsTopicTitle.SearchInput
  }

derive instance Newtype NewsTopic _
derive instance Generic NewsTopic _
derive instance Eq NewsTopic
derive instance Ord NewsTopic
derive newtype instance ReadForeign NewsTopic
derive newtype instance WriteForeign NewsTopic
derive newtype instance Random NewsTopic

instance Show NewsTopic where
  show = genericShow

newtype NewsTopicKey = NewsTopicKey NewsTopicId

derive instance Newtype NewsTopicKey _
instance ToAliasedPrimary NewsTopicKey where
  toAliasedPrimary (NewsTopicKey id) = { primary: toString id, aliases: [] }
derive newtype instance Eq NewsTopicKey
derive newtype instance Ord NewsTopicKey
derive instance Generic NewsTopicKey _

instance Show NewsTopicKey where
  show = genericShow

---- MagazineIssue 

instance IsPair MagazineIssueKey MagazineIssue MagazineIssueRecord MagazineIssueIndexNeeds () "magazineIssue" "magazineIssues" "articleMagazineIssueProjectionReadFind" GetArticleProjection where
  toKey (MagazineIssue { id }) = MagazineIssueKey id

  single = false

newtype MagazineIssue = MagazineIssue MagazineIssueRecord

type MagazineIssueRecord =
  { id :: MagazineIssueId
  , slug :: MagazineIssueSlug.Slug
  }

type MagazineIssueIndexNeeds = {}

derive instance Newtype MagazineIssue _
derive instance Generic MagazineIssue _
derive instance Eq MagazineIssue
derive instance Ord MagazineIssue
derive newtype instance ReadForeign MagazineIssue
derive newtype instance WriteForeign MagazineIssue
derive newtype instance Random MagazineIssue

instance Show MagazineIssue where
  show = genericShow

newtype MagazineIssueKey = MagazineIssueKey MagazineIssueId

derive newtype instance Eq MagazineIssueKey
derive newtype instance Ord MagazineIssueKey
derive newtype instance Random MagazineIssueKey
derive instance Generic MagazineIssueKey _

instance Show MagazineIssueKey where
  show = genericShow

instance ToAliasedPrimary MagazineIssueKey where
  toAliasedPrimary (MagazineIssueKey id) = { primary: toString id, aliases: [] }

---- CustomSection

instance IsPair CustomSectionKey CustomSection CustomSectionRecord CustomSectionIndexNeeds () "customSection" "customSections" "articleCustomSectionProjectionReadFind" GetArticleProjection where
  toKey (CustomSection { id }) = CustomSectionKey id

  single = false

newtype CustomSection = CustomSection CustomSectionRecord

type CustomSectionRecord =
  { id :: CustomSectionId.CustomSectionId
  , name :: CustomSectionName.Name
  }

type CustomSectionIndexNeeds = {}

derive instance Newtype CustomSection _
derive instance Generic CustomSection _
derive instance Eq CustomSection
derive instance Ord CustomSection
derive newtype instance ReadForeign CustomSection
derive newtype instance WriteForeign CustomSection
derive newtype instance Random CustomSection

instance Show CustomSection where
  show = genericShow

newtype CustomSectionKey = CustomSectionKey CustomSectionId.CustomSectionId

derive newtype instance Eq CustomSectionKey
derive newtype instance Ord CustomSectionKey
derive newtype instance Random CustomSectionKey
derive instance Generic CustomSectionKey _

instance Show CustomSectionKey where
  show = genericShow

instance ToAliasedPrimary CustomSectionKey where
  toAliasedPrimary (CustomSectionKey id) = { primary: toString id, aliases: [] }

-- Filter

type BookCoverFallbackIncluded = Boolean

data ArticleFilter
  = ArticleHasId ArticleId
  | ArticleHasNotId ArticleId
  | ArticleHasTheme Theme
  | ArticleHasLegacyId Int
  | ArticleHasTitle { title :: Title, weight :: Weight }
  | ArticleHasExactTitle Title
  | ArticleHasLead { lead :: Lead, weight :: Weight }
  | ArticleHasContent { content :: Content, weight :: Weight }
  | ArticleAuthorHasName { name :: Name, weight :: Weight }
  | ArticleAuthorHasExactName Name
  | ArticleAuthorHasId AuthorId
  | ArticleHasSlug Slug
  | ArticleBookHasName { name :: Name, weight :: Weight }
  | ArticleBookAuthorHasId AuthorId
  | ArticleIsAboutAtLeastOneBook
  | ArticleIsAboutAtLeastOneBookWithCover
  | ArticleHasAtLeastOneIllustration BookCoverFallbackIncluded
  | ArticleHasAtLeastOneLandscapeIllustration
  | ArticleMatches { query :: String, weight :: Weight }
  | ArticleIsAddedToNewsRelatedWhitelist Boolean
  | ArticleIsAddedToNewsRelatedBlacklist Boolean
  | ArticleMagazineIssueHasId MagazineIssueId
  | ArticleMagazineIssueHasSlug MagazineIssueSlug.Slug
  | ArticleHasMagazineIssuePageNumber
  | ArticleWrittenAtYear Time.Year
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

  compile e (ArticleHasTitle { title: title, weight: w }) = by @"title" (Matches { weight: w, expectation: e }) title
  compile _ (ArticleHasExactTitle title) = by @"title" EqualsUpToNormalization title

  compile e (ArticleHasLead { lead: lead, weight: w }) = by @"lead" (Matches { weight: w, expectation: e }) lead

  compile e (ArticleHasContent { content: content, weight: w }) = by @"content" (Matches { weight: w, expectation: e }) content

  compile e (ArticleAuthorHasName { name: name, weight: w }) = by @"author.name" (Matches { weight: w, expectation: e }) name
  compile _ (ArticleAuthorHasExactName name) = by @"author.name" EqualsUpToNormalization name
  compile _ (ArticleAuthorHasId id) = by @"author.id" StrictlyEquals id

  compile _ (ArticleHasSlug slug) = by @"slug" StrictlyEquals slug

  compile e (ArticleBookHasName { name: name, weight: w }) = by @"books.names" (Matches { weight: w, expectation: e }) [ name ]
  compile _ (ArticleBookAuthorHasId id) = by @"books.authors.ids" Contains [ id ]

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

  compile _ (ArticleIsAddedToNewsRelatedWhitelist b) = by @"addedToNewsRelatedWhitelist" StrictlyEquals b
  compile _ (ArticleIsAddedToNewsRelatedBlacklist b) = by @"addedToNewsRelatedBlacklist" StrictlyEquals b
  compile _ (ArticleMagazineIssueHasId id) = by @"magazineIssue.issue.id" StrictlyEquals id
  compile _ (ArticleMagazineIssueHasSlug slug) = by @"magazineIssue.issue.slug" StrictlyEquals slug
  compile _ ArticleHasMagazineIssuePageNumber = byExists @"magazineIssue.pageNumber"
  compile _ (ArticleWrittenAtYear year) = by @"writtenAt.year" StrictlyEquals year

  compile e (ArticleMatches { query: searchString, weight: w }) =
    byMatches
      w
      defaultInnerWeightA
      defaultInnerWeightB
      defaultInnerWeightC
      defaultInnerWeightD
      e
      searchString

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

type GET_ARTICLE_ARTICLE_PROJECTION_READ_FIND fx = (articleGetArticleProjectionReadFind :: Find Article | fx)
type GET_ARTICLE_ARTICLE_PROJECTION_READ fx =
  GET_ARTICLE_ARTICLE_PROJECTION_READ_FIND
    + GET_ARTICLE_PROJECTION_READ_SYNC_PROJECT
    + fx

findArticleById :: ∀ fx. ArticleId -> Run (GET_ARTICLE_ARTICLE_PROJECTION_READ + fx) (Maybe Article)
findArticleById id = findOneByKey (ArticleKey { id: Just id, slug: Nothing })

findArticleBySlug :: ∀ fx. Slug -> Run (GET_ARTICLE_ARTICLE_PROJECTION_READ + fx) (Maybe Article)
findArticleBySlug slug = findOneBy @Article @"slug" StrictlyEquals slug

-- Play 

play :: ∀ fx. LoadedEvent -> Run (GET_ARTICLE_PROJECTION_WRITE_OPS fx) Ɩ
play { event, at } = case event of
  ArticleDiscarded payload -> onArticleDiscarded payload
  ArticleWritten payload -> onArticleWritten at payload
  AuthorReferenced payload -> onAuthorReferenced payload
  EditorReferenced payload -> onEditorReferenced payload
  BookReferenced payload -> onBookReferenced payload
  NewsTopicAdded payload -> onNewsTopicAdded payload
  NewsTopicRemoved payload -> onNewsTopicRemoved payload
  ArticleAddedToNewsRelatedWhitelist payload -> onArticleAddedToNewsRelatedWhitelist payload
  ArticleRemovedFromNewsRelatedWhitelist payload -> onArticleRemovedFromNewsRelatedWhitelist payload
  ArticleAddedToNewsRelatedBlacklist payload -> onArticleAddedToNewsRelatedBlacklist payload
  ArticleRemovedFromNewsRelatedBlacklist payload -> onArticleRemovedFromNewsRelatedBlacklist payload
  AuthorDereferenced _ -> ηι
  BookDereferenced _ -> ηι
  MagazineIssueReferenced payload -> onMagazineIssueReferenced payload
  MagazineIssueDereferenced _ -> ηι
  EditorDereferenced _ -> ηι
  UserEmailChanged _ -> ηι
  UserRegistered _ -> ηι
  UserUnregistered _ -> ηι
  ArticleFeaturedOnFrontPage _ -> ηι
  ArticleQuoted _ -> ηι
  ArticleRead _ -> ηι
  NewsletterScheduled _ -> ηι
  MagazineCustomSectionAdded payload -> onMagazineCustomSectionAdded payload
  UserDonated _ -> ηι

---- Listeners

onArticleDiscarded :: ∀ fx. ArticleDiscarded.Payload -> Run (GET_ARTICLE_PROJECTION_WRITE_OPS fx) Ɩ
onArticleDiscarded { article } = delete $ ArticleKey { id: Just article, slug: Nothing }

onArticleWritten :: ∀ fx. Instant -> ArticleWritten.Payload -> Run (GET_ARTICLE_PROJECTION_WRITE_OPS fx) Ɩ
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
  , profitable
  , slug
  , magazineIssue
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

  fetchedMagazineIssue <- case magazineIssue of
    Nothing -> η Nothing
    Just (BaseMagazineIssue.MagazineIssue mi) -> do
      mMag <- get (MagazineIssueKey mi.issue)
      case mMag of
        Nothing -> η Nothing
        Just (MagazineIssue magRec) -> do
          resolvedSection <- case mi.section of
            Nothing -> η Nothing
            Just Intro -> η (Just Intro)
            Just FeatureIntro -> η (Just FeatureIntro)
            Just Feature -> η (Just Feature)
            Just (Custom cid) -> do
              mc <- get (CustomSectionKey cid)
              case mc of
                Nothing -> η Nothing
                Just (CustomSection cs) -> η (Just (Custom { id: cid, name: cs.name }))

          η $ Just $ Projected.MagazineIssue { issue: { id: mi.issue, slug: magRec.slug }, section: resolvedSection, pageNumber: mi.pageNumber, onCover: mi.onCover }

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
    , profitable
    , slug
    , writtenAt: WrittenAt.make at
    , addedToNewsRelatedWhitelist: false
    , addedToNewsRelatedBlacklist: false
    , magazineIssue: fetchedMagazineIssue
    , seo:
        { updatedAt: at
        }
    }

onAuthorReferenced :: ∀ fx. AuthorReferenced.Payload -> Run (GET_ARTICLE_PROJECTION_WRITE_OPS fx) Ɩ
onAuthorReferenced { id, name, biography, portrait } = add $ Author { id, name, biography, portrait }

onEditorReferenced :: ∀ fx. EditorReferenced.Payload -> Run (GET_ARTICLE_PROJECTION_WRITE_OPS fx) Ɩ
onEditorReferenced { id, name } = add $ Editor { id, name }

onBookReferenced :: ∀ fx. BookReferenced.Payload -> Run (GET_ARTICLE_PROJECTION_WRITE_OPS fx) Ɩ
onBookReferenced { id, name, year, cover, authors, editor } = add $ Book { id, name, year, cover, authors, editor }

onNewsTopicAdded :: ∀ fx. NewsTopicAdded.Payload -> Run (GET_ARTICLE_PROJECTION_WRITE_OPS fx) Ɩ
onNewsTopicAdded { id, searchInput } = add $ NewsTopic { id, searchInput }

onNewsTopicRemoved :: ∀ fx. NewsTopicRemoved.Payload -> Run (GET_ARTICLE_PROJECTION_WRITE_OPS fx) Ɩ
onNewsTopicRemoved { newsTopic } = delete $ NewsTopicKey newsTopic

onArticleAddedToNewsRelatedWhitelist :: ∀ fx. ArticleAddedToNewsRelatedWhitelist.Payload -> Run (GET_ARTICLE_PROJECTION_WRITE_OPS fx) Ɩ
onArticleAddedToNewsRelatedWhitelist { article } =
  patch (ArticleKey { id: Just article, slug: Nothing }) (unwrap ▷ (_ { addedToNewsRelatedWhitelist = true }) ▷ wrap)

onArticleRemovedFromNewsRelatedWhitelist :: ∀ fx. ArticleRemovedFromNewsRelatedWhitelist.Payload -> Run (GET_ARTICLE_PROJECTION_WRITE_OPS fx) Ɩ
onArticleRemovedFromNewsRelatedWhitelist { article } =
  patch (ArticleKey { id: Just article, slug: Nothing }) (unwrap ▷ (_ { addedToNewsRelatedWhitelist = false }) ▷ wrap)

onMagazineIssueReferenced :: ∀ fx. MagazineIssueReferenced.Payload -> Run (GET_ARTICLE_PROJECTION_WRITE_OPS fx) Ɩ
onMagazineIssueReferenced { id, slug } = add $ MagazineIssue { id, slug }

onMagazineCustomSectionAdded :: ∀ fx. MagazineCustomSectionAdded.Payload -> Run (GET_ARTICLE_PROJECTION_WRITE_OPS fx) Ɩ
onMagazineCustomSectionAdded { id, name } = add $ CustomSection { id, name }

onArticleAddedToNewsRelatedBlacklist :: ∀ fx. ArticleAddedToNewsRelatedBlacklist.Payload -> Run (GET_ARTICLE_PROJECTION_WRITE_OPS fx) Ɩ
onArticleAddedToNewsRelatedBlacklist { article } =
  patch (ArticleKey { id: Just article, slug: Nothing }) (unwrap ▷ (_ { addedToNewsRelatedBlacklist = true }) ▷ wrap)

onArticleRemovedFromNewsRelatedBlacklist :: ∀ fx. ArticleRemovedFromNewsRelatedBlacklist.Payload -> Run (GET_ARTICLE_PROJECTION_WRITE_OPS fx) Ɩ
onArticleRemovedFromNewsRelatedBlacklist { article } =
  patch (ArticleKey { id: Just article, slug: Nothing }) (unwrap ▷ (_ { addedToNewsRelatedBlacklist = false }) ▷ wrap)
