module Core.Mod.Article.Lead.Message.Query.Opt where

import Proem

import Core.Message.Query.Payload (Need)
import Util.Html.Clean.Clean (UntagOpt)
import Data.Maybe (Maybe)
import Core.Mod.Article.Content.Excerpt.CutStrategy (CutStrategy)

type FallbackOpt =
  { cutStrategy :: CutStrategy
  , newlineReplacement :: Maybe String
  }

type LeadOpt =
  { fallbackToContentExcerpt :: Maybe FallbackOpt
  , untagHtml :: UntagOpt
  }

type LeadInnerNeeds =
  { isFallback :: Need Ɩ Ɩ
  }
