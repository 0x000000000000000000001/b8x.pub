module Util.Type.Variant.Encoding.Encoding.Test.EncodeValueJson where

import Proem
import Yoga.JSON as Yoga.JSON

import Yoga.JSON (writeImpl)
import Data.Variant (Variant, inj)
import Effect.Aff (Aff)
import Util.Type.Variant.Encoding.Encoding (encodeValueJson)
import Test.Spec (SpecT, it, describe)
import Test.Util.Assert ((=?))

type TestVariant = Variant
  ( foo :: String
  , bar :: Int
  , baz :: { a :: Int }
  )

fullModuleName :: String
fullModuleName = "Util.Type.Variant.Encoding.Encoding.Test.EncodeValueJson"

spec :: SpecT Aff Ɩ Aff Ɩ
spec = describe fullModuleName do
  it "encodes a string value in a variant" do
    let v = inj (π :: Π "foo") "hello" :: TestVariant
    Yoga.JSON.writeJSON (encodeValueJson v) =? Yoga.JSON.writeJSON (writeImpl "hello")

  it "encodes an int value in a variant" do
    let v = inj (π :: Π "bar") 42 :: TestVariant
    Yoga.JSON.writeJSON (encodeValueJson v) =? Yoga.JSON.writeJSON (writeImpl 42)

  it "encodes a record value in a variant" do
    let v = inj (π :: Π "baz") { a: 1 } :: TestVariant
    Yoga.JSON.writeJSON (encodeValueJson v) =? Yoga.JSON.writeJSON (writeImpl { a: 1 })