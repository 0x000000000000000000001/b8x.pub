module Core.Mod.Author.Biography.Biography where

import Core.Mod.Html.Html (NonEmptyHtml)
import Data.Maybe (Maybe)

type Biography_ = NonEmptyHtml

type Biography = Maybe Biography_
