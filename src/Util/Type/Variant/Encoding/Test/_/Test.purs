module Util.Type.Variant.Encoding.Encoding.Test.Test where

import Proem

import Effect.Aff (Aff)
import Test.Spec (SpecT)
import Util.Type.Variant.Encoding.Encoding.Test.ReadForeign as ReadForeign
import Util.Type.Variant.Encoding.Encoding.Test.DecodeJsonWith as DecodeJsonWith
import Util.Type.Variant.Encoding.Encoding.Test.WriteForeign as WriteForeign
import Util.Type.Variant.Encoding.Encoding.Test.EncodeValueJson as EncodeValueJson
import Util.Type.Variant.Encoding.Encoding.Test.EncodeJsonWith as EncodeJsonWith

spec :: SpecT Aff Ɩ Aff Ɩ
spec = do
  EncodeValueJson.spec
  WriteForeign.spec
  EncodeJsonWith.spec
  ReadForeign.spec
  DecodeJsonWith.spec