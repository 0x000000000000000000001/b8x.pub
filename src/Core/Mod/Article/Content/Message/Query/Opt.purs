module Core.Mod.Article.Content.Message.Query.Opt where

import Proem

import Data.Generic.Rep (class Generic)
import Data.Maybe (Maybe(..))
import Data.Show.Generic (genericShow)
import Util.Html.Clean.Clean (UntagOpt, TagList(..))
import Util.Json.TaggedSum (genericReadImplWithDefaultOpt, genericWriteImplWithDefaultOpt)
import Util.Type.Random (class Random, random)
import Yoga.JSON (class ReadForeign, class WriteForeign)

data ExcerptOpt
  = No { newlineReplacement :: Maybe String }
  | Yes { newlineReplacement :: Maybe String }
  | YesBestMatchingWords { newlineReplacement :: Maybe String, words :: Array String }

derive instance Eq ExcerptOpt
derive instance Generic ExcerptOpt _
instance Show ExcerptOpt where
  show = genericShow

instance WriteForeign ExcerptOpt where
  writeImpl = genericWriteImplWithDefaultOpt

instance ReadForeign ExcerptOpt where
  readImpl = genericReadImplWithDefaultOpt

instance Random ExcerptOpt where
  random = do
    b <- random
    if b then η (Yes { newlineReplacement: Just " " }) else η (No { newlineReplacement: Nothing })

type ContentOpt =
  { excerpt :: ExcerptOpt
  , untagHtml :: UntagOpt
  }

type ContentInnerNeeds = Ɩ

defaultContentOpt :: ContentOpt
defaultContentOpt =
  { excerpt: No { newlineReplacement: Nothing }
  , untagHtml:
      { whitelist: Tags []
      , blacklistInWhitelist: Tags []
      }
  }
