module Util.Test where

import Proem

import Effect.Aff (Aff)
import Test.Spec (SpecT)
import Util.Debug.Test as Debug
import Util.Html.Test as Html
import Util.Type.String.Test.Test as String
import Util.Type.Variant.Test as Variant

spec :: SpecT Aff Ɩ Aff Ɩ
spec = do
  Debug.spec
  Html.spec
  String.spec
  Variant.spec
