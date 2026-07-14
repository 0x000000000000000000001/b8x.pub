module Inter.Api.Social.Meta.Route.Article.Placeholder where

import Proem

import Data.Maybe (Maybe(..))
import Inter.Api.Social.Meta.Type (Meta, defaultDescription)

placeholderMeta :: Meta
placeholderMeta =
  { title: Just "Article"
  , description: Just $ "Article. " <> defaultDescription
  , image: Nothing
  }

