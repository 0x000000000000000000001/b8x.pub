module Util.Html.Clean.Test.UntagOnly where

import Proem

import Effect.Aff (Aff)
import Test.Spec (SpecT, it, describe)
import Test.Util.Assert ((=?))
import Util.Html.Clean.Clean (untagOnly)

fullModuleName :: String
fullModuleName = "Util.Html.Clean.Test.UntagOnly"

spec :: SpecT Aff Ɩ Aff Ɩ
spec = describe fullModuleName do

  it "removes only the specified tags" do
    let html = "<div>Hello <strong>World</strong>!</div>"
    untagOnly [ "strong" ] false html =? "<div>Hello World!</div>"

  it "removes multiple specified tags" do
    let html = "<div>Hello <strong>World</strong>! <a href=\"#\">Link</a></div>"
    untagOnly [ "strong", "a" ] false html =? "<div>Hello World! Link</div>"

  it "ignores tags not in the forbidden list" do
    let html = "<div>Hello <strong>World</strong>!</div>"
    untagOnly [ "a" ] false html =? html

  it "removes specified tags with attributes" do
    let html = "<p>Text <img src=\"test.jpg\" alt=\"test\" /> here</p>"
    untagOnly [ "img" ] false html =? "<p>Text  here</p>"
