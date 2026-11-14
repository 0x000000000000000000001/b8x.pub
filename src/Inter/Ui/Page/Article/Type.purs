module Inter.Ui.Page.Article.Type where

import Proem

import Data.Lens.Record (prop)
import Data.Lens (Lens')
import Data.Map (Map)
import Halogen (HalogenM, Slot)
import Inter.Ui.Type.Query (NoQuery)
import Inter.Ui.UiM (UiM)
import Inter.Ui.Type.State (WithId)
import Inter.Ui.Type.Remote (Remote)
import Inter.Ui.Type.Model (UiArticle, UiAuthorInfo, UiSearchArticle)
import Inter.Ui.Capability.ArticleCache.ArticleCache (AlreadyKnown)
import Data.Maybe (Maybe)
import Inter.Ui.Mod.ArticleCard.Type as ArticleCard
import Inter.Ui.Mod.AdPlaceholder.Type as AdPlaceholder
import Inter.Ui.Mod.Link.Type as Link
import Core.Mod.Article.Slug.Slug (Slug)
import Core.Mod.Author.Id.Id (AuthorId)
import Core.Mod.Author.Name.Name as Author
import Web.UIEvent.MouseEvent (MouseEvent)
import Inter.Ui.Type.Device (Device)

type Input = { slug :: Slug, context :: Device }


data Output = ArticleNotFound

type Slots = 
  (articleCard :: Slot ArticleCard.Query ArticleCard.Output String
  , adPlaceholder :: Slot AdPlaceholder.Query AdPlaceholder.Output String
  )

type State = WithId
  ( input :: Input
  , article :: Remote (Maybe UiArticle)
  , cachedInfo :: Maybe AlreadyKnown
  , relatedArticles :: Remote (Array UiSearchArticle)
  , issueArticles :: Remote (Array UiSearchArticle)
  , bookAuthorInfos :: Map AuthorId (Remote UiAuthorInfo)
  , context :: Device
  )

article' = π :: Π "article"

_article :: ∀ a r. Lens' { article :: a | r } a
_article = prop article'

relatedArticles' = π :: Π "relatedArticles"

_relatedArticles :: ∀ a r. Lens' { relatedArticles :: a | r } a
_relatedArticles = prop relatedArticles'

issueArticles' = π :: Π "issueArticles"

_issueArticles :: ∀ a r. Lens' { issueArticles :: a | r } a
_issueArticles = prop issueArticles'

data Action
  = Initialize
  | Load
  | Receive Input
  | HandleArticleCardOutput String
  | HandleAdLinkOutput Link.Output
  | ClickAuthor MouseEvent { id :: AuthorId, name :: Author.Name, ofBook :: Boolean }
  | LoadBookAuthorInfo AuthorId

type Query :: ∀ k. k -> Type
type Query = NoQuery

type ArticleM a = HalogenM State Action Slots Output UiM a
