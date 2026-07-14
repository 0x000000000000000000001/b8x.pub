module Core.Mod.Article.Sources.Sources
  (Sources
  ) where

import Core.Mod.Html.Html (NonEmptyHtml)
import Data.Maybe (Maybe)

type Sources = Maybe NonEmptyHtml
