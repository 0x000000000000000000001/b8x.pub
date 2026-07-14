module Util.Type.Variant.Encoding.Encoding.Test.DecodeJsonWith where

import Proem
import Data.Either as Data.Either
import Control.Monad.Except as Control.Monad.Except
import Yoga.JSON as Yoga.JSON

import Yoga.JSON (class ReadForeign, writeImpl)
import Data.Either (Either(..))
import Data.Newtype (class Newtype)
import Data.Variant (Variant, inj)
import Effect.Aff (Aff)
import Util.Type.String.String (Case(..))
import Util.Type.Variant.Encoding.Encoding (defaultEncoding)
import Util.Type.Variant.Encoding.Encoding as Variant
import Test.Spec (SpecT, it, describe)
import Test.Util.Assert ((=?))

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
fullModuleName = "Util.Type.Variant.Encoding.Encoding.Test.DecodeJsonWith"

spec :: SpecT Aff Ɩ Aff Ɩ
spec = describe fullModuleName do
  it "decodes a string value from { type, value }" do
    let input = writeImpl { type: "foo", value: "hello" }
    let expected = Right (inj (π :: Π "foo") "hello" :: TestVariant)
    Control.Monad.Except.runExcept (Variant.decodeJsonWith defaultEncoding input) =? expected

  it "decodes an int value from { type, value }" do
    let input = writeImpl { type: "bar", value: 42 }
    let expected = Right (inj (π :: Π "bar") 42 :: TestVariant)
    Control.Monad.Except.runExcept (Variant.decodeJsonWith defaultEncoding input) =? expected

  it "decodes a custom type value from { type, value }" do
    let input = writeImpl { a: "Baz", b: { nested: 100 } }
    let expected = Right (inj (π :: Π "baz") (MyComplexType { nested: 100 }) :: TestVariant)
    Control.Monad.Except.runExcept (Variant.decodeJsonWith (defaultEncoding { tag = { key: "a", case: Pascal }, valueKey = "b" }) input) =? expected

  it "fails to decode when type is missing" do
    let input = Yoga.JSON.writeImpl { value: 42 }
    let result = Variant.decodeJsonWith @TestVariant defaultEncoding input
    Data.Either.isLeft (Control.Monad.Except.runExcept result) =? true

  it "fails to decode when value is missing" do
    let input = Yoga.JSON.writeImpl { type: "bar" }
    let result = Variant.decodeJsonWith @TestVariant defaultEncoding input
    Data.Either.isLeft (Control.Monad.Except.runExcept result) =? true

  it "fails to decode when type is unknown" do
    let input = writeImpl { type: "baz", value: 42 }
    let result = Variant.decodeJsonWith @TestVariant defaultEncoding input
    Data.Either.isLeft (Control.Monad.Except.runExcept result) =? true
