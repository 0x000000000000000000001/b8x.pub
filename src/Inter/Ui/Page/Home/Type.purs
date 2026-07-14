module Inter.Ui.Page.Home.Type where

import Proem

import Network.RemoteData (RemoteData)
import Data.Lens (Lens')
import Data.Lens.Record (prop)
import Data.Maybe (Maybe)
import Core.Mod.Article.Theme.Theme (Theme) as ArticleTheme
import Halogen (HalogenM, Slot)
import Inter.Ui.Type.Output (NoOutput)
import Inter.Ui.Type.Query (NoQuery)
import Inter.Ui.Type.Model (UiSearchArticle, UiFrontPageResult)
import Inter.Ui.Mod.ArticleCard.Type as ArticleCard
import Inter.Ui.Type.Remote (Remote)
import Inter.Ui.Type.State (WithId)
import Inter.Ui.Mod.Newsletter.Type as Newsletter
import Inter.Ui.UiM (UiM)
import Effect.Ref (Ref)
import Halogen.Query (ForkId)
import Core.Mod.Article.Id.Id (ArticleId)

import Core.Feat.Review.Message.Query.GetArticleQuote.Result as GetArticleQuote
import Inter.Ui.Mod.Link.Type as Link

type Input = { theme :: Maybe ArticleTheme.Theme }

type Output = NoOutput

type Slots =
  (articleCard :: Slot ArticleCard.Query ArticleCard.Output String
  , newsletter :: Slot Newsletter.Query Newsletter.Output Unit
  , linkQuote :: Slot Link.Query Link.Output Unit
  )

type FrontPage = Remote UiFrontPageResult

type State = WithId
  (frontPage :: FrontPage
  , articleQuote :: RemoteData String GetArticleQuote.Result
  , newsArticles :: RemoteData String (Array UiSearchArticle)
  , mostReadArticles :: RemoteData String (Array UiSearchArticle)
  , newsletterArticles :: RemoteData String (Array UiSearchArticle)
  , input :: Input
  , bandsForkId :: Maybe (Ref (Maybe ForkId))
  , lastTriggeredFrontPageIds :: Maybe (Ref (Maybe (Array ArticleId)))
  )

frontPage' = π :: Π "frontPage"
_frontPage = prop frontPage' :: Lens' State FrontPage

articleQuote' = π :: Π "articleQuote"
_articleQuote = prop articleQuote' :: Lens' State (RemoteData String GetArticleQuote.Result)

newsArticles' = π :: Π "newsArticles"
_newsArticles = prop newsArticles' :: Lens' State (RemoteData String (Array UiSearchArticle))

mostReadArticles' = π :: Π "mostReadArticles"
_mostReadArticles = prop mostReadArticles' :: Lens' State (RemoteData String (Array UiSearchArticle))

newsletterArticles' = π :: Π "newsletterArticles"
_newsletterArticles = prop newsletterArticles' :: Lens' State (RemoteData String (Array UiSearchArticle))

bandsForkId' = π :: Π "bandsForkId"
_bandsForkId = prop bandsForkId' :: Lens' State (Maybe (Ref (Maybe ForkId)))

lastTriggeredFrontPageIds' = π :: Π "lastTriggeredFrontPageIds"
_lastTriggeredFrontPageIds = prop lastTriggeredFrontPageIds' :: Lens' State (Maybe (Ref (Maybe (Array ArticleId))))

data Action
  = Load
  | Receive Input
  | HandleArticleCardOutput ArticleCard.Output
  | HandleNewsletterOutput Newsletter.Output
  | HandleQuoteLinkOutput Link.Output

type Query :: ∀ k. k -> Type
type Query = NoQuery

type HomeM a = HalogenM State Action Slots Output UiM a
