module Core.Mod.Article.Notes.Notes
  (Notes
  ) where

import Core.Mod.Html.Html (NonEmptyHtml)
import Data.Maybe (Maybe)

type Notes = Maybe NonEmptyHtml
