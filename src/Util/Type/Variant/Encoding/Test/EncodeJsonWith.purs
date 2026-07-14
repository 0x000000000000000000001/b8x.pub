module Util.Type.Variant.Encoding.Encoding.Test.EncodeJsonWith where

import Proem
import Yoga.JSON as Yoga.JSON

import Yoga.JSON (class WriteForeign, writeImpl)
import Data.Newtype (class Newtype, wrap)
import Data.Variant (Variant, inj)
import Effect.Aff (Aff)
import Test.Spec (SpecT, describe, it)
import Test.Util.Assert ((=?))
import Util.Type.String.String (Case(..))
import Util.Type.Variant.Encoding.Encoding (defaultEncoding)
import Util.Type.Variant.Encoding.Encoding as Variant

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
fullModuleName = "Util.Type.Variant.Encoding.Encoding.Test.EncodeJsonWith"

spec :: SpecT Aff Ɩ Aff Ɩ
spec = describe fullModuleName do
  it "encodes a string value into { type, value }" do
    let v = inj (π :: Π "foo") "hello" :: TestVariant
    let expected = writeImpl { type: "foo", value: "hello" }
    Yoga.JSON.writeJSON (Variant.encodeJsonWith defaultEncoding v) =? Yoga.JSON.writeJSON expected

  it "encodes an int value into { type, value }" do
    let v = inj (π :: Π "bar") 42 :: TestVariant
    let expected = writeImpl { type: "bar", value: 42 }
    Yoga.JSON.writeJSON (Variant.encodeJsonWith defaultEncoding v) =? Yoga.JSON.writeJSON expected

  it "encodes a custom type value into { type, value }" do
    let v = inj (π :: Π "baz") (wrap 100) :: TestVariant
    let expected = writeImpl { a: "Baz", b: { custom: 100 } }
    Yoga.JSON.writeJSON (Variant.encodeJsonWith (defaultEncoding { tag = { key: "a", case: Pascal }, valueKey = "b" }) v) =? Yoga.JSON.writeJSON expected
