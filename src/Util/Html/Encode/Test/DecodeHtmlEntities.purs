module Util.Html.Encode.Test.DecodeHtmlEntities where

import Proem

import Effect.Aff (Aff)
import Test.Spec (SpecT, it, describe)
import Test.Util.Assert ((=?))
import Util.Html.Encode.Encode (decodeHtmlEntities)

fullModuleName :: String
fullModuleName = "Util.Html.Encode.Test.DecodeHtmlEntities"

spec :: SpecT Aff Ɩ Aff Ɩ
spec = describe fullModuleName do

  it "decodes common HTML entities" do
    decodeHtmlEntities "&lt;div&gt;" =? "<div>"
    decodeHtmlEntities "&amp;" =? "&"
    decodeHtmlEntities "&quot;hello&quot;" =? "\"hello\""
    decodeHtmlEntities "&#39;world&#39;" =? "'world'"
    decodeHtmlEntities "&nbsp;" =? " "

  it "decodes complex HTML with multiple entities" do
    let input = "&lt;p class=&quot;text&quot;&gt;Hello &amp; world&lt;/p&gt;"
    let expected = "<p class=\"text\">Hello & world</p>"
    decodeHtmlEntities input =? expected

  it "decodes numeric character references" do
    decodeHtmlEntities "&#60;div&#62;" =? "<div>"
    decodeHtmlEntities "&#x3C;div&#x3E;" =? "<div>"
    decodeHtmlEntities "&#233;" =? "é"
    decodeHtmlEntities "Hello world" =? "Hello world"
    decodeHtmlEntities "<div>No entities here</div>" =? "<div>No entities here</div>"

  it "handles empty strings" do
    decodeHtmlEntities "" =? ""
