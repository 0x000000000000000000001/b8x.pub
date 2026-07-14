module Util.Html.Dom.Polyfill where

import Proem

import Effect (Effect)
import Effect.Unsafe (unsafePerformEffect)

foreign import polyfillDOMParser :: Effect Ɩ

unsafeWithDOMParserPolyfill :: ∀ a. (Ɩ -> a) -> a
unsafeWithDOMParserPolyfill f = unsafePerformEffect do
  polyfillDOMParser
  η $ f ι
