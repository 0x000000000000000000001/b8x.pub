module Core.Mod.Article.Lead.Clean
  (cleanHtml
  , cleanHtml_
  , defaultUntagWhitelist
  ) where

import Proem

import Core.Mod.Html.Html (NonEmptyHtml, unsafeFromString)
import Data.String (trim)
import Util.Html.Clean.Clean (TagList(..), UntagOpt, removeComments, untag)
import Util.Html.Encode.Encode (decodeHtmlEntities)
import Util.Type.String.String (collapseSpaces, collapseSpacesWithAtLeastOneNewline)
import Util.Type.String.ToString (toString)

defaultUntagWhitelist :: TagList
defaultUntagWhitelist = Tags [ "em", "u", "strong", "b", "i", "mark", "code", "sup", "sub", "s", "strike", "span", "abbr", "cite", "q", "small", "del", "ins", "time", "kbd", "var", "samp" ]

cleanHtml_ :: UntagOpt -> String -> String
cleanHtml_ opts str =
  removeComments str
    # untag opts false
    # decodeHtmlEntities
    # collapseSpaces false
    # trim
    # collapseSpacesWithAtLeastOneNewline false " "
    # collapseSpaces false

cleanHtml :: UntagOpt -> NonEmptyHtml -> NonEmptyHtml
cleanHtml opts lead =
  unsafeFromString $
    cleanHtml_
      opts
      (toString lead)
