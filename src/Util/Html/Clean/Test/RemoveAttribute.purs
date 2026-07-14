module Util.Html.Clean.Test.RemoveAttribute where

import Proem

import Effect.Aff (Aff)
import Test.Spec (SpecT, it, describe)
import Test.Util.Assert ((=?))
import Util.Html.Clean.Clean (removeAttribute)

fullModuleName :: String
fullModuleName = "Util.Html.Clean.Test.RemoveAttribute"

spec :: SpecT Aff Ɩ Aff Ɩ
spec = describe fullModuleName do

  it "removes a simple attribute with value" do
    let tag = """<div style="color:red;" class="my-class">"""
    removeAttribute "style" tag =? """<div class="my-class">"""

  it "removes attribute from beginning of tag" do
    let tag = """<div style="color:red;" class="my-class" id="test">"""
    removeAttribute "style" tag =? """<div class="my-class" id="test">"""

  it "removes attribute from middle of tag" do
    let tag = """<div class="my-class" style="color:red;" id="test">"""
    removeAttribute "style" tag =? """<div class="my-class" id="test">"""

  it "removes attribute from end of tag" do
    let tag = """<div class="my-class" id="test" style="color:red;">"""
    removeAttribute "style" tag =? """<div class="my-class" id="test">"""

  it "removes attribute with complex value" do
    let tag = """<div style="color:red; background-color: blue; margin: 10px;" class="test">"""
    removeAttribute "style" tag =? """<div class="test">"""

  it "removes attribute with empty value" do
    let tag = """<div style="" class="test">"""
    removeAttribute "style" tag =? """<div class="test">"""

  it "removes attribute with single quotes (should not work - only handles double quotes)" do
    let tag = """<div style='color:red;' class="test">"""
    removeAttribute "style" tag =? """<div style='color:red;' class="test">"""

  it "handles tag with only the target attribute" do
    let tag = """<div style="color:red;">"""
    removeAttribute "style" tag =? """<div>"""

  it "returns unchanged tag when attribute not found" do
    let tag = """<div class="my-class" id="test">"""
    removeAttribute "style" tag =? """<div class="my-class" id="test">"""

  it "returns unchanged tag when similar attribute name exists" do
    let tag = """<div class="my-style-class" id="test">"""
    removeAttribute "style" tag =? """<div class="my-style-class" id="test">"""

  it "handles self-closing tags" do
    let tag = """<img src="test.jpg" style="width:100px;" alt="test" />"""
    removeAttribute "style" tag =? """<img src="test.jpg" alt="test" />"""

  it "handles attributes with special characters in values" do
    let tag = """<div style="content: 'Hello \"World\"'; color: red;" class="test">"""
    removeAttribute "style" tag =? """<div class="test">"""
