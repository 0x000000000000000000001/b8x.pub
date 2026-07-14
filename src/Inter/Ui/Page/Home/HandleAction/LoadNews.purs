module Inter.Ui.Page.Home.HandleAction.LoadNews (loadNews) where

import Proem

import Core.Message.Query.Result (Fold, Return(..))
import Inter.Ui.Type.Model (UiSearchArticle)
import Core.Feat.Review.Message.Query.ListNewsRelatedArticles.Query (ListNewsRelatedArticles(..))
import Core.Message.Query.Result as QueryResult
import Inter.Ui.Page.Home.Util (bandArticleNeeds)
import Inter.Ui.Page.Home.Util as HomeUtil
import Core.Mod.Article.Id.Id (ArticleId)
import Data.Array as Array
import Data.Maybe (Maybe(..))
import Halogen (get)
import Inter.Ui.Page.Home.Type (HomeM, _newsArticles)
import Record as Record
import Type.Proxy (Proxy(..))
import Inter.Ui.Remote (queryModify')
import Network.RemoteData (RemoteData(..))

loadNews :: HomeM Ɩ
loadNews = do
  st <- get
  let
    theme = st.input.theme

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

  ø $ queryModify' (\res -> map HomeUtil.toUiSearchArticle res.articles) κηι _newsArticles $ ListNewsRelatedArticles
    { theme
    , blacklist
    , needs: Record.delete (Proxy @"magazineIssuePageNumber") $ Record.delete (Proxy @"magazineSection") $ Record.delete (Proxy @"onFrontPages") $ Record.delete (Proxy @"seoUpdatedAt") bandArticleNeeds
    }
