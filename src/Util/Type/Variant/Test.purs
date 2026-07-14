module Util.Type.Variant.Test where

import Proem

import Effect.Aff (Aff)
import Util.Type.Variant.Encoding.Encoding.Test.Test as Encoding
import Test.Spec (SpecT)

spec :: SpecT Aff Ɩ Aff Ɩ
spec = do
  Encoding.spec