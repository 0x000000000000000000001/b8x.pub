module Util.Html.Clean.Test.CleanAttributesInTag where

import Proem

import Effect.Aff (Aff)
import Test.Spec (SpecT, it, describe)
import Test.Util.Assert ((=?))
import Util.Html.Clean.Clean (cleanAttributesInTag)

fullModuleName :: String
fullModuleName = "Util.Html.Clean.Test.CleanAttributesInTag"

spec :: SpecT Aff Ɩ Aff Ɩ
spec = describe fullModuleName do

  it "removes single attribute without data attributes" do
    let tag = """<div style="color:red;" class="my-class">"""
    cleanAttributesInTag tag [ "style" ] false =? """<div class="my-class">"""

  it "removes multiple attributes without data attributes" do
    let tag = """<div style="color:red;" class="my-class" id="test">"""
    cleanAttributesInTag tag [ "style", "class" ] false =? """<div id="test">"""

  it "removes attributes and data attributes when dataOnesToo is true" do
    let tag = """<div style="color:red;" class="my-class" data-id="123" id="test">"""
    cleanAttributesInTag tag [ "style" ] true =? """<div class="my-class" id="test">"""

  it "only removes specified attributes when dataOnesToo is false" do
    let tag = """<div style="color:red;" class="my-class" data-id="123" id="test">"""
    cleanAttributesInTag tag [ "style" ] false =? """<div class="my-class" data-id="123" id="test">"""

  it "removes multiple data attributes when dataOnesToo is true" do
    let tag = """<div data-id="123" data-value="test" class="my-class" data-extra="info">"""
    cleanAttributesInTag tag [ "class" ] true =? """<div>"""

  it "handles empty attribute array" do
    let tag = """<div style="color:red;" class="my-class">"""
    cleanAttributesInTag tag [] false =? """<div style="color:red;" class="my-class">"""

  it "handles empty attribute array with dataOnesToo true" do
    let tag = """<div style="color:red;" data-id="123" class="my-class">"""
    cleanAttributesInTag tag [] true =? """<div style="color:red;" class="my-class">"""

  it "handles non-existent attributes" do
    let tag = """<div class="my-class" id="test">"""
    cleanAttributesInTag tag [ "style", "nonexistent" ] false =? """<div class="my-class" id="test">"""

  it "handles tag with only target attributes" do
    let tag = """<div style="color:red;" class="my-class">"""
    cleanAttributesInTag tag [ "style", "class" ] false =? """<div>"""

  it "handles empty tag string" do
    cleanAttributesInTag "" [ "style" ] false =? ""

  it "handles tag without any attributes" do
    let tag = "<div>"
    cleanAttributesInTag tag [ "style", "class" ] true =? "<div>"

  it "preserves order of remaining attributes" do
    let tag = """<div id="first" style="color:red;" class="middle" title="last">"""
    cleanAttributesInTag tag [ "style" ] false =? """<div id="first" class="middle" title="last">"""

  it "handles attributes with complex values" do
    let tag = """<div style="color:red; background: url('image.jpg');" class="my-class">"""
    cleanAttributesInTag tag [ "style" ] false =? """<div class="my-class">"""

  it "handles attributes with escaped quotes" do
    let tag = """<div data-content="He said \"Hello\"" class="my-class" title="test">"""
    cleanAttributesInTag tag [ "class" ] true =? """<div title="test">"""

  it "handles multiple consecutive data attributes" do
    let tag = """<div data-a="1" data-b="2" data-c="3" class="keep">"""
    cleanAttributesInTag tag [] true =? """<div class="keep">"""

  it "combines attribute removal and data attribute removal correctly" do
    let tag = """<div style="color:red;" data-id="123" class="my-class" data-value="test" id="keep">"""
    cleanAttributesInTag tag [ "style", "class" ] true =? """<div id="keep">"""