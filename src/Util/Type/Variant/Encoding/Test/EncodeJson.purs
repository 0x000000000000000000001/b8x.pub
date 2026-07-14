module Util.Type.Variant.Encoding.Encoding.Test.WriteForeign where

import Proem
import Yoga.JSON as Yoga.JSON

import Yoga.JSON (class WriteForeign, writeImpl)
import Data.Newtype (class Newtype)
import Data.Variant (Variant, inj)
import Effect.Aff (Aff)
import Util.Type.Variant.Encoding.Encoding as Variant
import Test.Spec (SpecT, it, describe)
import Test.Util.Assert ((=?))

newtype MyCustomType = MyCustomType Int

derive instance Newtype MyCustomType _
instance WriteForeign MyCustomType where
  writeImpl (MyCustomType i) = writeImpl { custom: i }

type TestVariant = Variant
  ( foo :: String
  , bar :: Int
  , baz :: MyCustomType
  )

fullModuleName :: String
fullModuleName = "Util.Type.Variant.Encoding.Encoding.Test.WriteForeign"

spec :: SpecT Aff Ɩ Aff Ɩ
spec = describe fullModuleName do
  it "encodes a string value into { type, value }" do
    let v = inj (π :: Π "foo") "hello" :: TestVariant
    let expected = writeImpl { type: "foo", value: "hello" }
    Yoga.JSON.writeJSON (Variant.writeVariantImpl v) =? Yoga.JSON.writeJSON expected

  it "encodes an int value into { type, value }" do
    let v = inj (π :: Π "bar") 42 :: TestVariant
    let expected = writeImpl { type: "bar", value: 42 }
    Yoga.JSON.writeJSON (Variant.writeVariantImpl v) =? Yoga.JSON.writeJSON expected

  it "encodes a custom type value into { type, value }" do
    let v = inj (π :: Π "baz") (MyCustomType 100) :: TestVariant
    let expected = writeImpl { type: "baz", value: { custom: 100 } }
    Yoga.JSON.writeJSON (Variant.writeVariantImpl v) =? Yoga.JSON.writeJSON expected
