module Inter.Api.Social.Meta.Route.PlaceholderIndex where

import Proem

import Inter.Api.Social.Meta.Route.Article.Placeholder as Article
import Inter.Api.Social.Meta.Route.Home.Placeholder as Home
import Inter.Api.Social.Meta.Type (Meta)
import Inter.Ui.Capability.Navigate.Navigate as UiRoute
import Data.Maybe (Maybe(..))

placeholderMeta :: UiRoute.Route -> Meta
placeholderMeta = case _ of
  UiRoute.Home _ -> Home.placeholderMeta Nothing
  UiRoute.Theme theme _ -> Home.placeholderMeta $ Just theme
  UiRoute.Article _ _ -> Article.placeholderMeta
  UiRoute.Donate _ -> { title: Nothing, description: Nothing, image: Nothing }
  UiRoute.NotFound -> { title: Nothing, description: Nothing, image: Nothing }
