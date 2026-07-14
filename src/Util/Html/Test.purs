module Util.Html.Test where

import Proem

import Effect.Aff (Aff)
import Test.Spec (SpecT)
import Util.Html.Clean.Test.Test as Clean
import Util.Html.Encode.Test.Test as Encode

spec :: SpecT Aff Ɩ Aff Ɩ
spec = do
  Clean.spec
  Encode.spec
