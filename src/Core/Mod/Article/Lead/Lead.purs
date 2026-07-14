module Core.Mod.Article.Lead.Lead
  (Lead
  ) where

import Core.Mod.Html.Html (NonEmptyHtml)
import Data.Maybe (Maybe)

type Lead = Maybe NonEmptyHtml
