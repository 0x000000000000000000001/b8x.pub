module Core.Mod.Article.Lead.Message.Query.Result where

import Proem
import Core.Message.Query.Result (Return)
import Core.Mod.Html.Html (NonEmptyHtml)
import Data.Lens (Lens')
import Data.Lens.Record (prop)
import Data.Maybe (Maybe)

type Lead =
  { lead :: Return (Maybe NonEmptyHtml)
  , isFallback :: Return Boolean
  }

_lead :: Lens' Lead (Return (Maybe NonEmptyHtml))
_lead = prop (π @"lead")
