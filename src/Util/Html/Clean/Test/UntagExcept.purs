module Util.Html.Clean.Test.UntagExcept where

import Proem

import Effect.Aff (Aff)
import Test.Spec (SpecT, it, describe)
import Test.Util.Assert ((=?))
import Util.Html.Clean.Clean (untagExcept)

fullModuleName :: String
fullModuleName = "Util.Html.Clean.Test.UntagExcept"

spec :: SpecT Aff Ɩ Aff Ɩ
spec = describe fullModuleName do
  it "removes all tags if whitelist is empty" do
    let html = "<div>Hello <p>World</p>!</div>"
    untagExcept [] false html =? "Hello World!"

  it "preserves a whitelisted self-closing tag" do
    let html = "<p>Text <img src='x.png' /> here</p>"
    untagExcept [ "img" ] false html =? "Text <img src='x.png' /> here"

  it "preserves a whitelisted tag and its closing tag" do
    let html = "<div>Look at this: <iframe src='video.mp4'></iframe></div>"
    untagExcept [ "iframe" ] false html =? "Look at this: <iframe src='video.mp4'></iframe>"

  it "preserves multiple whitelisted tags" do
    let html = "<div><img src='1.jpg'><p>Text</p><iframe src='v'></iframe></div>"
    untagExcept [ "img", "iframe" ] false html =? "<img src='1.jpg'>Text<iframe src='v'></iframe>"

  it "strips tags that start with the whitelisted name but are different" do
    let html = "<img src='x.png'><imgx>bad</imgx><img-custom>tag</img-custom>"
    untagExcept [ "img" ] false html =? "<img src='x.png'>badtag"

  it "handles spaces correctly when stripping" do
    let html = "<div><p>Text</p> <img src='x'></div>"
    untagExcept [ "img" ] false html =? "Text <img src='x'>"

  it "preserves tags when replaceWithSpace is true" do
    let html = "<p>Text</p><img src='x'><div>More</div>"
    untagExcept [ "img" ] true html =? " Text <img src='x'> More "
