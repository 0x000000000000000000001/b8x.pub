module Util.Html.Clean.Test.FindUnescapedQuote where

import Proem

import Data.Maybe (Maybe(..))
import Effect.Aff (Aff)
import Test.Spec (SpecT, it, describe)
import Test.Util.Assert ((=?))
import Util.Html.Clean.Clean (findUnescapedQuote)

fullModuleName :: String
fullModuleName = "Util.Html.Clean.Test.FindUnescapedQuote"

spec :: SpecT Aff Ɩ Aff Ɩ
spec = describe fullModuleName do

  it "finds simple unescaped quote" do
    let str = """Hello "World" """
    findUnescapedQuote str 0 =? Just 6

  it "finds quote at the beginning" do
    let str = """"Hello World" """
    findUnescapedQuote str 0 =? Just 0

  it "finds quote at the end" do
    let str = """Hello World" """
    findUnescapedQuote str 0 =? Just 11

  it "skips escaped quotes and finds unescaped one" do
    let str = """value with \"escaped\" and " end"""
    findUnescapedQuote str 0 =? Just 27

  it "returns Nothing when no quotes found" do
    let str = "no quotes here"
    findUnescapedQuote str 0 =? Nothing

  it "returns Nothing when only escaped quotes" do
    let str = """only \\"escaped\\" quotes"""
    findUnescapedQuote str 0 =? Nothing

  it "handles multiple escaped quotes before unescaped one" do
    let str = """start \"first\" then \"second\" finally " end"""
    findUnescapedQuote str 0 =? Just 40

  it "starts search from specified position" do
    let str = """"first" then "second" """
    findUnescapedQuote str 8 =? Just 13

  it "skips quotes before start position" do
    let str = """"skip this" but find "this" """
    findUnescapedQuote str 15 =? Just 21

  it "handles escaped quote at string boundary" do
    let str = """ends with \" """
    findUnescapedQuote str 0 =? Nothing

  it "handles quote immediately after escape character" do
    findUnescapedQuote """\"quote""" 0 =? Nothing
    findUnescapedQuote """\\"quote""" 0 =? Nothing

  it "handles empty string" do
    findUnescapedQuote "" 0 =? Nothing

  it "handles single quote, escaped or not" do
    findUnescapedQuote "\"" 0 =? Just 0
    findUnescapedQuote "\\\"" 0 =? Nothing

  it "finds quote when starting position is beyond string length" do
    let str = "short"
    findUnescapedQuote str 100 =? Nothing

  it "handles complex HTML attribute value" do
    let str = """content: 'Hello \"World\"!' and " final"""
    findUnescapedQuote str 0 =? Just 32
