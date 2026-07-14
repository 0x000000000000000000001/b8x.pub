module Util.Html.Clean.Test.RemoveComments where

import Proem

import Effect.Aff (Aff)
import Test.Spec (SpecT, it, describe)
import Test.Util.Assert ((=?))
import Util.Html.Clean.Clean (removeComments)

fullModuleName :: String
fullModuleName = "Util.Html.Clean.Test.RemoveComments"

spec :: SpecT Aff Ɩ Aff Ɩ
spec = describe fullModuleName do

  it "removes single HTML comment" do
    let html = """<div>Content</div><!-- This is a comment -->"""
    removeComments html =? """<div>Content</div>"""

  it "removes multiple HTML comments" do
    let html = """<!-- First comment --><div>Content</div><!-- Second comment -->"""
    removeComments html =? """<div>Content</div>"""

  it "removes comment from middle of content" do
    let html = """<div>Before<!-- comment -->After</div>"""
    removeComments html =? """<div>BeforeAfter</div>"""

  it "removes nested content in comments" do
    let html = """<div>Content</div><!-- <span>This should be removed</span> -->"""
    removeComments html =? """<div>Content</div>"""

  it "handles comment at the beginning" do
    let html = """<!-- Start comment --><div>Content</div>"""
    removeComments html =? """<div>Content</div>"""

  it "handles comment at the end" do
    let html = """<div>Content</div><!-- End comment -->"""
    removeComments html =? """<div>Content</div>"""

  it "handles empty comment" do
    let html = """<div>Content</div><!---->"""
    removeComments html =? """<div>Content</div>"""

  it "handles comment with special characters" do
    let html = """<div>Content</div><!-- Comment with <>&"' special chars -->"""
    removeComments html =? """<div>Content</div>"""

  it "handles comment with multiline content" do
    let
      html =
        """<div>Content</div><!--
    This is a
    multiline comment
    -->"""
    removeComments html =? """<div>Content</div>"""

  it "returns unchanged string when no comments" do
    let html = """<div>Content with no comments</div>"""
    removeComments html =? """<div>Content with no comments</div>"""

  it "handles empty string" do
    removeComments "" =? ""

  it "handles string with only comment" do
    let html = """<!-- Only a comment -->"""
    removeComments html =? ""

  it "handles malformed comment (no closing tag)" do
    let html = """<div>Content</div><!-- Unclosed comment"""
    removeComments html =? """<div>Content</div><!-- Unclosed comment"""

  it "handles malformed comment (only closing tag)" do
    let html = """<div>Content</div>--> Orphaned closing"""
    removeComments html =? """<div>Content</div>--> Orphaned closing"""

  it "handles consecutive comments" do
    let html = """<!--First--><!--Second-->Content<!--Third-->"""
    removeComments html =? "Content"

  it "handles comments within complex HTML" do
    let html = """<html><head><!-- Meta tags --><title>Test</title></head><body><!-- Body content --><div>Content</div></body></html>"""
    removeComments html =? """<html><head><title>Test</title></head><body><div>Content</div></body></html>"""

  it "preserves HTML tags inside content" do
    let html = """<div><strong>Bold</strong> text</div><!-- comment -->"""
    removeComments html =? """<div><strong>Bold</strong> text</div>"""

  it "handles comments with HTML-like content" do
    let html = """<div>Content</div><!-- <div class="fake">Not real HTML</div> -->"""
    removeComments html =? """<div>Content</div>"""

  it "handles comment containing comment-like strings" do
    let html = """<div>Content</div><!-- This contains <!-- fake nesting --> -->"""
    removeComments html =? """<div>Content</div> -->"""

  it "handles multiple comments on same line" do
    let html = """<!-- Comment 1 --><span>Text</span><!-- Comment 2 -->"""
    removeComments html =? """<span>Text</span>"""