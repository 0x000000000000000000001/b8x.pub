module Util.Type.String.Test.PadRight where

import Proem

import Effect.Aff (Aff)
import Util.Type.String.String (padRight)
import Test.Spec (SpecT, it, describe)
import Test.Util.Assert ((=?))

fullModuleName :: String
fullModuleName = "Util.Type.String.Test.PadRight"

spec :: SpecT Aff Ɩ Aff Ɩ
spec = describe fullModuleName do

  it "pads string with spaces on the right" do
    padRight 4 ' ' "hi" =? "hi  "

  it "pads string with zeros on the right" do
    padRight 5 '0' "123" =? "12300"

  it "does not pad when string is already wide enough" do
    padRight 3 '0' "abc" =? "abc"

  it "does not pad when string is wider than requested width" do
    padRight 2 '0' "hello" =? "hello"

  it "pads with custom character" do
    padRight 6 '*' "test" =? "test**"

  it "handles empty string" do
    padRight 3 '-' "" =? "---"

  it "handles width of 0" do
    padRight 0 '0' "test" =? "test"

  it "handles negative width" do
    padRight (-1) '0' "test" =? "test"

  it "pads to exact width" do
    padRight 10 '.' "hello" =? "hello....."

  it "preserves string when width equals length" do
    padRight 5 '0' "hello" =? "hello"

  it "pads unicode characters correctly" do
    padRight 5 '·' "hi" =? "hi···"

  it "handles multicharacter string padding" do
    padRight 7 '_' "abc" =? "abc____"

  it "pads numbers correctly" do
    padRight 4 '0' "42" =? "4200"
    padRight 3 '0' "8" =? "800"

  it "preserves trailing characters" do
    padRight 5 '0' "100" =? "10000"
