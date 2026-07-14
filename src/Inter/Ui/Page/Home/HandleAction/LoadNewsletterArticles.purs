module Inter.Ui.Page.Home.HandleAction.LoadNewsletterArticles (loadNewsletterArticles) where

import Proem

import Core.Message.Query.Result (Fold, Return(..))
import Inter.Ui.Type.Model (UiSearchArticle)
import Core.Message.Query.Result as QueryResult
import Core.Feat.Review.Message.Query.ListNewsletterArticles.Query (ListNewsletterArticles(..))
import Core.Feat.Review.Message.Query.ListNewsletterArticles.Field.Newsletter as Newsletter
import Core.Mod.Article.Id.Id (ArticleId)
import Data.Maybe (Maybe(..))
import Data.Array as Array
import Halogen (get)
import Inter.Ui.Page.Home.Type (HomeM, _newsletterArticles)
import Inter.Ui.Page.Home.Util (bandArticleNeeds)
import Inter.Ui.Page.Home.Util as HomeUtil
import Inter.Ui.Remote (queryModify')
import Network.RemoteData (RemoteData(..))
import Record as Record
import Core.Message.Query.Payload (Need(..))
import Type.Proxy (Proxy(..))

loadNewsletterArticles :: HomeM Ɩ
loadNewsletterArticles = do
  st <- get
  let
    newsletter = Newsletter.Recent

    blacklist :: Array ArticleId
    blacklist = case st.frontPage of
      Success fp ->
        let
          extractId :: QueryResult.Return (Fold (Maybe ArticleId) (Maybe UiSearchArticle)) -> Maybe ArticleId
          extractId (Given (QueryResult.Folded (Just id))) = Just id
          extractId (Given (QueryResult.Unfolded (Just a))) = case a.id of
            Given id -> Just id
            _ -> Nothing
          extractId _ = Nothing
        in
          Array.catMaybes
            [ extractId fp.topLeft
            , extractId fp.topRight
            , extractId fp.center
            , extractId fp.bottomLeft
            , extractId fp.bottomRight
            ]
      _ -> []

  ø $ queryModify' (\res -> map HomeUtil.toUiSearchArticle res.articles) κηι _newsletterArticles $ ListNewsletterArticles
    { blacklist
    , needs: Record.delete (Proxy @"magazineIssuePageNumber") $ Record.delete (Proxy @"magazineSection") $ Record.insert (Proxy @"newsletters") NotNeeded $ Record.delete (Proxy @"onFrontPages") $ Record.delete (Proxy @"seoUpdatedAt") bandArticleNeeds
    , newsletter
    , illustrationRequired: true
    }
