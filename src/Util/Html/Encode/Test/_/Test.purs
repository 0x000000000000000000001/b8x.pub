module Util.Html.Encode.Test.Test where

import Proem

import Effect.Aff (Aff)
import Test.Spec (SpecT)
import Util.Html.Encode.Test.DecodeHtmlEntities as DecodeHtmlEntities
import Util.Html.Encode.Test.EncodeHtmlEntities as EncodeHtmlEntities

spec :: SpecT Aff Ɩ Aff Ɩ
spec = do
  DecodeHtmlEntities.spec
  EncodeHtmlEntities.spec