module Inter.Api.Social.Meta.Route.Home.Placeholder where

import Core.Mod.Article.Theme.Theme (Theme)
import Data.Maybe (Maybe(..))
import Inter.Api.Social.Meta.Type (Meta, defaultMeta)
import Util.I18n (Language(..), translate)

placeholderMeta :: Maybe Theme -> Meta
placeholderMeta mTheme = defaultMeta
  { title = case mTheme of
      Just theme -> Just (translate Fr theme)
      Nothing -> Nothing
  }
