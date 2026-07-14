module Util.Type.String.Test.PadLeft where

import Proem

import Effect.Aff (Aff)
import Test.Spec (SpecT, it, describe)
import Test.Util.Assert ((=?))
import Util.Type.String.String (padLeft)

fullModuleName :: String
fullModuleName = "Util.Type.String.Test.PadLeft"

spec :: SpecT Aff Ɩ Aff Ɩ
spec = describe fullModuleName do

  it "pads single digit number with zero" do
    padLeft 2 '0' "5" =? "05"

  it "pads single digit number with zero to width 3" do
    padLeft 3 '0' "7" =? "007"

  it "does not pad when string is already wide enough" do
    padLeft 2 '0' "12" =? "12"

  it "does not pad when string is wider than requested width" do
    padLeft 2 '0' "123" =? "123"

  it "pads with spaces" do
    padLeft 4 ' ' "hi" =? "  hi"

  it "pads with custom character" do
    padLeft 5 '*' "abc" =? "**abc"

  it "handles empty string" do
    padLeft 3 '0' "" =? "000"

  it "handles width of 0" do
    padLeft 0 '0' "test" =? "test"

  it "handles negative width" do
    padLeft (-1) '0' "test" =? "test"

  it "pads to exact width" do
    padLeft 10 '-' "hello" =? "-----hello"

  it "preserves string when width equals length" do
    padLeft 5 '0' "hello" =? "hello"

  it "pads unicode characters correctly" do
    padLeft 5 '·' "hi" =? "···hi"

  it "handles multicharacter string padding" do
    padLeft 7 '_' "test" =? "___test"

  it "pads numbers correctly" do
    padLeft 4 '0' "42" =? "0042"
    padLeft 3 '0' "8" =? "008"

  it "preserves leading characters" do
    padLeft 5 '0' "001" =? "00001"
