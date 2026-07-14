module Util.Html.Encode.Test.EncodeHtmlEntities where

import Proem

import Effect.Aff (Aff)
import Test.Spec (SpecT, it, describe)
import Test.Util.Assert ((=?))
import Util.Html.Encode.Encode (encodeHtmlEntities)

fullModuleName :: String
fullModuleName = "Util.Html.Encode.Test.EncodeHtmlEntities"

spec :: SpecT Aff Ɩ Aff Ɩ
spec = describe fullModuleName do

  it "encodes HTML entities" do
    encodeHtmlEntities "<div>" =? "&#x3C;div&#x3E;"
    encodeHtmlEntities "Hello & world" =? "Hello &#x26; world"
    encodeHtmlEntities "\"quoted text\"" =? "&#x22;quoted text&#x22;"

  it "handles empty strings" do
    encodeHtmlEntities "" =? ""