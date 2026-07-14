module Util.Html.Clean.Test.Untag where

import Proem

import Effect.Aff (Aff)
import Test.Spec (SpecT, it, describe)
import Test.Util.Assert ((=?))
import Util.Html.Clean.Clean (untagAll)

fullModuleName :: String
fullModuleName = "Util.Html.Clean.Test.Untag"

spec :: SpecT Aff Ɩ Aff Ɩ
spec = describe fullModuleName do

  it "removes simple HTML tags" do
    let html = "<div>Hello World!</div>"
    untagAll false html =? "Hello World!"

  it "removes nested HTML tags" do
    let html = "<div>Hello <strong>World</strong>!</div>"
    untagAll false html =? "Hello World!"

  it "removes tags with attributes" do
    let html = "<p class=\"text\">This is a <a href=\"#\">link</a>.</p>"
    untagAll false html =? "This is a link."

  it "handles self-closing tags" do
    let html = "<div>Line 1<br/>Line 2</div>"
    untagAll false html =? "Line 1Line 2"

  it "handles empty tags" do
    let html = "<div></div>"
    untagAll false html =? ""

  it "handles text without tags" do
    let html = "Plain text without any tags"
    untagAll false html =? "Plain text without any tags"

  it "removes multiple nested levels" do
    let html = "<div><p><span><strong>Nested</strong></span></p></div>"
    untagAll false html =? "Nested"

  it "preserves spaces between tags" do
    let html = "<p>Word1</p> <p>Word2</p>"
    untagAll false html =? "Word1 Word2"

  it "handles tags with multiple attributes" do
    let html = "<a href=\"#\" class=\"link\" data-id=\"123\">Click here</a>"
    untagAll false html =? "Click here"

  it "removes tags with newlines" do
    let html = "<div\n  class=\"test\"\n>Content</div>"
    untagAll false html =? "Content"

  it "handles consecutive tags" do
    let html = "<strong><em>Bold and italic</em></strong>"
    untagAll false html =? "Bold and italic"

  it "preserves special characters in text" do
    let html = "<div>Special chars: &amp; &lt; &gt; &quot;</div>"
    untagAll false html =? "Special chars: &amp; &lt; &gt; &quot;"

  it "handles mixed content" do
    let html = "Before<div>Inside</div>After"
    untagAll false html =? "BeforeInsideAfter"

  it "handles unclosed tags gracefully" do
    let html = "<div>Content without closing tag"
    untagAll false html =? "Content without closing tag"

  it "handles unmatched closing tag" do
    let html = "Content</div>"
    untagAll false html =? "Content"

  it "handles empty string" do
    let html = ""
    untagAll false html =? ""

  it "handles string with only tags" do
    let html = "<div><span></span></div>"
    untagAll false html =? ""

  it "handles multiple spaces" do
    let html = "<p>Word1   Word2</p>"
    untagAll false html =? "Word1   Word2"

  it "preserves unicode characters" do
    let html = "<div>Hello 世界 🌍</div>"
    untagAll false html =? "Hello 世界 🌍"
