module Util.Json.TaggedSum where

import Proem

import Foreign (Foreign, F)
import Data.Generic.Rep (class Generic)
import Yoga.JSON.Generics.TaggedSumRep (class ReadGenericTaggedSumRep, class WriteGenericTaggedSumRep)
import Yoga.JSON.Generics.TaggedSumRep as Tagged

-- | Fixes a known impedance mismatch between `JSON.stringify` and PureScript's `TaggedSumRep` generic ADT decoders.
-- | 
-- | In `purescript-yoga-json`, fields of type `Maybe a` that evaluate to `Nothing` are intentionally 
-- | serialized as `undefined` so that `JSON.stringify` drops the key entirely (optimizing network payloads).
-- | However, `genericReadForeignTaggedSum` strictly requires the `value` key to be present on the JSON object 
-- | before it delegates to the inner decoder (e.g. `Maybe`), causing it to crash prematurely on dropped keys.
-- | 
-- | For example, for an ADT like `data Return a = Given a | NotGiven`:
-- | If `a` is `Maybe String` and evaluates to `Nothing`, `purescript-yoga-json` writes `{"type": "Given"}`.
-- | When reading, `genericReadForeignTaggedSum` crashes because the `"value"` key is entirely missing.
-- | 
-- | This interceptor function checks if an object is an ADT constructor (has a `type` string) but is missing 
-- | the `value` key. If so, it injects `value: undefined` (or `null` in PHP) to satisfy the strict ADT decoder, 
-- | allowing the inner `Maybe` decoder to properly evaluate it to `Nothing`.
foreign import fixTaggedSumRepMissingValue :: Foreign -> Foreign

-- | A drop-in replacement for `genericReadForeignTaggedSum` that automatically applies the `fixTaggedSumRepMissingValue` patch.
genericReadImpl :: ∀ a rep. Generic a rep => ReadGenericTaggedSumRep rep => Tagged.Options -> Foreign -> F a
genericReadImpl options = Tagged.genericReadForeignTaggedSum options ◁ fixTaggedSumRepMissingValue

genericWriteImpl :: ∀ a rep. Generic a rep => WriteGenericTaggedSumRep rep => Tagged.Options -> a -> Foreign
genericWriteImpl = Tagged.genericWriteForeignTaggedSum

genericReadImplWithDefaultOpt :: ∀ a rep. Generic a rep => ReadGenericTaggedSumRep rep => Foreign -> F a
genericReadImplWithDefaultOpt = genericReadImpl Tagged.defaultOptions

genericWriteImplWithDefaultOpt :: ∀ a rep. Generic a rep => WriteGenericTaggedSumRep rep => a -> Foreign
genericWriteImplWithDefaultOpt = genericWriteImpl Tagged.defaultOptions
