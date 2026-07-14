module Util.Type.Variant.Encoding.Encoding.Test.ReadForeign where

import Proem
import Data.Either as Data.Either
import Control.Monad.Except as Control.Monad.Except
import Yoga.JSON as Yoga.JSON

import Yoga.JSON (class ReadForeign, writeImpl)
import Data.Either (Either(..))
import Data.Variant (Variant, inj)
import Effect.Aff (Aff)
import Util.Type.Variant.Encoding.Encoding as Variant
import Test.Spec (SpecT, it, describe)
import Test.Util.Assert ((=?))
import Data.Newtype (class Newtype)

newtype MyComplexType = MyComplexType { nested :: Int }

derive instance Newtype MyComplexType _
derive newtype instance Eq MyComplexType
derive newtype instance Show MyComplexType
derive newtype instance ReadForeign MyComplexType

type TestVariant = Variant
  ( foo :: String
  , bar :: Int
  , baz :: MyComplexType
  )

fullModuleName :: String
fullModuleName = "Util.Type.Variant.Encoding.Encoding.Test.ReadForeign"

spec :: SpecT Aff Ɩ Aff Ɩ
spec = describe fullModuleName do
  it "decodes a string value from { type, value }" do
    let input = writeImpl { type: "foo", value: "hello" }
    let expected = Right (inj (π @"foo") "hello" :: TestVariant)
    Control.Monad.Except.runExcept (Variant.readImpl input) =? expected

  it "decodes an int value from { type, value }" do
    let input = writeImpl { type: "bar", value: 42 }
    let expected = Right (inj (π @"bar") 42 :: TestVariant)
    Control.Monad.Except.runExcept (Variant.readImpl input) =? expected

  it "decodes a custom type value from { type, value }" do
    let input = writeImpl { type: "baz", value: { nested: 100 } }
    let expected = Right (inj (π @"baz") (MyComplexType { nested: 100 }) :: TestVariant)
    Control.Monad.Except.runExcept (Variant.readImpl input) =? expected

  it "fails to decode when type is missing" do
    let input = Yoga.JSON.writeImpl { value: 42 }
    let result = Variant.readImpl @TestVariant input
    Data.Either.isLeft (Control.Monad.Except.runExcept result) =? true

  it "fails to decode when value is missing" do
    let input = Yoga.JSON.writeImpl { type: "bar" }
    let result = Variant.readImpl @TestVariant input
    Data.Either.isLeft (Control.Monad.Except.runExcept result) =? true

  it "fails to decode when type is unknown" do
    let input = writeImpl { type: "baz", value: 42 }
    let result = Variant.readImpl @TestVariant input
    Data.Either.isLeft (Control.Monad.Except.runExcept result) =? true
