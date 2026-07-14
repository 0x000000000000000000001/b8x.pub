module Util.Html.Clean.Test.RemoveDataAttributes where

import Proem

import Effect.Aff (Aff)
import Test.Spec (SpecT, it, describe)
import Test.Util.Assert ((=?))
import Util.Html.Clean.Clean (removeDataAttributes)

fullModuleName :: String
fullModuleName = "Util.Html.Clean.Test.RemoveDataAttributes"

spec :: SpecT Aff Ɩ Aff Ɩ
spec = describe fullModuleName do

  it "removes a single data attribute" do
    let tag = """<div data-id="123" class="test">"""
    removeDataAttributes tag =? """<div class="test">"""

  it "removes multiple data attributes" do
    let tag = """<div data-id="123" data-value="test" class="my-class">"""
    removeDataAttributes tag =? """<div class="my-class">"""

  it "removes data attributes from beginning of tag" do
    let tag = """<div data-first="value" class="test" id="myid">"""
    removeDataAttributes tag =? """<div class="test" id="myid">"""

  it "removes data attributes from middle of tag" do
    let tag = """<div class="test" data-middle="value" id="myid">"""
    removeDataAttributes tag =? """<div class="test" id="myid">"""

  it "removes data attributes from end of tag" do
    let tag = """<div class="test" id="myid" data-last="value">"""
    removeDataAttributes tag =? """<div class="test" id="myid">"""

  it "handles tag with only data attributes" do
    let tag = """<div data-id="123" data-value="test">"""
    removeDataAttributes tag =? """<div>"""

  it "returns unchanged tag when no data attributes present" do
    let tag = """<div class="test" id="myid" style="color:red;">"""
    removeDataAttributes tag =? """<div class="test" id="myid" style="color:red;">"""

  it "handles data attributes with empty values" do
    let tag = """<div data-empty="" class="test">"""
    removeDataAttributes tag =? """<div class="test">"""

  it "handles data attributes with hyphenated names" do
    let tag = """<div data-user-id="123" data-item-count="5" class="container">"""
    removeDataAttributes tag =? """<div class="container">"""

  it "handles data attributes with numbers in names" do
    let tag = """<div data-test1="value1" data-test2="value2" class="widget">"""
    removeDataAttributes tag =? """<div class="widget">"""

  it "preserves non-data attributes that contain 'data' in their names" do
    let tag = """<div class="metadata" id="update-info" style="color:red;">"""
    removeDataAttributes tag =? """<div class="metadata" id="update-info" style="color:red;">"""

  it "handles self-closing tags with data attributes" do
    let tag = """<img src="test.jpg" data-lazy="true" alt="test" />"""
    removeDataAttributes tag =? """<img src="test.jpg" alt="test" />"""

  it "handles multiple consecutive data attributes" do
    let tag = """<div data-a="1" data-b="2" data-c="3" data-d="4" class="test">"""
    removeDataAttributes tag =? """<div class="test">"""

  it "handles data attributes with special characters in values" do
    let tag = """<div data-message="Hello \"World\"!" class="alert">"""
    removeDataAttributes tag =? """<div class="alert">"""

  it "handles empty tag string" do
    removeDataAttributes "" =? ""

  it "handles tag without any attributes" do
    let tag = """<div>"""
    removeDataAttributes tag =? """<div>"""