module Util.I18n where

import Proem

import Data.Variant (Variant)
import Heterogeneous.Folding (class Folding, hfoldl, class HFoldl)

data Language = En | Fr

derive instance Eq Language

class Translate a where
  translate :: Language -> a -> String

data TranslateVariant_ = TranslateVariant_ Language

instance (Translate a) => Folding TranslateVariant_ sym a String where
  folding (TranslateVariant_ language) _ item = translate language item

instance (HFoldl TranslateVariant_ Ɩ (Variant r) String) => Translate (Variant r) where
  translate language = hfoldl (TranslateVariant_ language) ι

