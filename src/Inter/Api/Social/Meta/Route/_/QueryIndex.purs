module Inter.Api.Social.Meta.Route.QueryIndex where

import Proem

import Effect.Aff (Aff)
import Inter.Api.ApiM (Context)
import Inter.Api.Social.Meta.Route.Article.Query as Article
import Inter.Api.Social.Meta.Route.Home.Query as Home
import Inter.Api.Social.Meta.Type (Meta)
import Inter.Ui.Capability.Navigate.Navigate as UiRoute
import Data.Maybe (Maybe(..))
import Util.I18n (Language(..), translate)
import Util.Type.String.ToString (toString)

queryMeta :: Context -> UiRoute.Route -> Aff (Maybe Meta)
queryMeta _ (UiRoute.Home _) = Home.queryMeta
queryMeta _ (UiRoute.Theme theme _) = do
  meta <- Home.queryMeta
  η $ (_ { title = Just (translate Fr theme) }) <$> meta
queryMeta ctx (UiRoute.Article slug _) = Article.queryMeta ctx (toString slug)
queryMeta _ (UiRoute.Donate _) = η Nothing
queryMeta _ UiRoute.NotFound = η Nothing
