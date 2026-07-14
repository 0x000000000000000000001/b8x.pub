module Util.Html.Clean.Test.CleanAttributesInTags where

import Proem

import Effect.Aff (Aff)
import Test.Spec (SpecT, it, describe)
import Test.Util.Assert ((=?))
import Util.Html.Clean.Clean (cleanAttributesInTags)

fullModuleName :: String
fullModuleName = "Util.Html.Clean.Test.CleanAttributesInTags"

spec :: SpecT Aff Ɩ Aff Ɩ
spec = describe fullModuleName do

  it "cleans attributes from single tag" do
    let html = """<div style="color:red;" class="my-class">Content</div>"""
    cleanAttributesInTags html [ "style" ] false =? """<div class="my-class">Content</div>"""

  it "cleans attributes from multiple tags" do
    let html = """<div style="color:red;" class="test">Content</div><p class="paragraph" id="para">Text</p>"""
    cleanAttributesInTags html [ "style", "class" ] false =? """<div>Content</div><p id="para">Text</p>"""

  it "preserves content between tags" do
    let html = """<div class="test">Hello World</div><span>More text</span>"""
    cleanAttributesInTags html [ "class" ] false =? """<div>Hello World</div><span>More text</span>"""

  it "handles nested tags" do
    let html = """<div class="outer"><span style="font-weight:bold;">Inner</span></div>"""
    cleanAttributesInTags html [ "class", "style" ] false =? """<div><span>Inner</span></div>"""

  it "removes data attributes when dataOnesToo is true" do
    let html = """<div data-id="123" class="test">Content</div>"""
    cleanAttributesInTags html [ "class" ] true =? """<div>Content</div>"""

  it "preserves data attributes when dataOnesToo is false" do
    let html = """<div data-id="123" class="test">Content</div>"""
    cleanAttributesInTags html [ "class" ] false =? """<div data-id="123">Content</div>"""

  it "handles self-closing tags" do
    let html = """<img src="image.jpg" class="photo" alt="Photo"/>"""
    cleanAttributesInTags html [ "class" ] false =? """<img src="image.jpg" alt="Photo"/>"""

  it "handles mixed content with text and tags" do
    let html = """Plain text <strong class="bold">bold text</strong> more plain text"""
    cleanAttributesInTags html [ "class" ] false =? """Plain text <strong>bold text</strong> more plain text"""

  it "handles empty HTML string" do
    cleanAttributesInTags "" [ "style", "class" ] false =? ""

  it "handles HTML with no tags" do
    let html = "Just plain text with no HTML tags"
    cleanAttributesInTags html [ "style", "class" ] false =? "Just plain text with no HTML tags"

  it "handles empty attribute array" do
    let html = """<div style="color:red;" class="test">Content</div>"""
    cleanAttributesInTags html [] false =? """<div style="color:red;" class="test">Content</div>"""

  it "handles empty attribute array with dataOnesToo true" do
    let html = """<div style="color:red;" data-id="123" class="test">Content</div>"""
    cleanAttributesInTags html [] true =? """<div style="color:red;" class="test">Content</div>"""

  it "handles malformed tags gracefully" do
    let html = """<div class="test" unclosed tag content"""
    cleanAttributesInTags html [ "class" ] false =? """<div class="test" unclosed tag content"""

  it "processes complex HTML document" do
    let html = """<html><head><title class="page-title">Test</title></head><body class="main"><h1 style="color:blue;">Header</h1><p class="text">Content</p></body></html>"""
    cleanAttributesInTags html [ "class" ] false =? """<html><head><title>Test</title></head><body><h1 style="color:blue;">Header</h1><p>Content</p></body></html>"""

  it "handles tags with multiple data attributes" do
    let html = """<div data-id="123" data-value="test" class="container" data-extra="info">Content</div>"""
    cleanAttributesInTags html [] true =? """<div class="container">Content</div>"""

  it "handles quotes in attribute values" do
    let html = """<div title="He said \"Hello\"" class="test">Content</div>"""
    cleanAttributesInTags html [ "class" ] false =? """<div title="He said \"Hello\"">Content</div>"""

  it "handles special characters in content" do
    let html = """<p class="text">Content with <>&"' special chars</p>"""
    cleanAttributesInTags html [ "class" ] false =? """<p>Content with <>&"' special chars</p>"""

  it "processes multiple nested levels" do
    let html = """<div class="level1"><div class="level2"><span class="level3">Deep content</span></div></div>"""
    cleanAttributesInTags html [ "class" ] false =? """<div><div><span>Deep content</span></div></div>"""

  it "combines all cleaning options correctly" do
    let html = """<div style="color:red;" class="test" data-id="123" id="keep"><span data-value="test" class="inner">Text</span></div>"""
    cleanAttributesInTags html [ "style", "class" ] true =? """<div id="keep"><span>Text</span></div>"""