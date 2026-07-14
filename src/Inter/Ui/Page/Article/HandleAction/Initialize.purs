module Inter.Ui.Page.Article.HandleAction.Initialize
  ( initialize
  ) where

import Proem

import Inter.Ui.Page.Article.HandleAction.Load (load)
import Inter.Ui.Page.Article.Type (ArticleM)

import Halogen (gets, modify_)
import Inter.Ui.Capability.ArticleCache.Trans (getArticleCache)

import Inter.Ui.Capability.Navigate.Trans (updateMeta)
import Inter.Api.Social.Meta.Route.Article.Shared (toAbsoluteWatermark)
import Util.Type.String.ToString (toString)
import Data.Maybe (Maybe(..))
import Data.Newtype (unwrap)
import Util.Html.Clean.Clean (clean)

initialize :: ArticleM Ɩ
initialize = do
  slug <- gets (_.input ▷ _.slug)
  cached <- getArticleCache (toString slug)
  modify_ _ { cachedInfo = cached }

  case cached of
    Just info -> do
      let
        titleStr = Just (clean false (unwrap info.title))
        descriptionStr = map (clean false ◁ unwrap) info.lead.lead
        mImageSrc = map _.src info.illustration
        watermarkUrl = toAbsoluteWatermark mImageSrc Nothing
      updateMeta $ Just
        { title: titleStr
        , description: descriptionStr
        , image: Just watermarkUrl
        }
    Nothing -> ηι

  load
