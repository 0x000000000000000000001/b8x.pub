module Util.Debug.Stash.Stash.Test.UnsafeStash where

import Proem

import Data.Maybe (Maybe(..))
import Effect.Aff (Aff)
import Util.Debug.Stash.Stash (unsafeStash, unsafeGetStash, unsafeDropStash)
import Test.Spec (SpecT, it, describe)
import Test.Util.Assert ((=?))

fullModuleName :: String
fullModuleName = "Util.Debug.Stash.Stash.Test.UnsafeStash"

spec :: SpecT Aff Ɩ Aff Ɩ
spec = describe fullModuleName do

  it "stores and retrieves a string value" do
    ι =? unsafeDropStash "US-test-key"
    ι =? unsafeStash "US-test-key" "hello"
    unsafeGetStash "US-test-key" =? Just "hello"

  it "stores and retrieves an integer value" do
    ι =? unsafeDropStash "US-counter"
    ι =? unsafeStash "US-counter" 42
    unsafeGetStash "US-counter" =? Just 42

  it "stores and retrieves a boolean value" do
    ι =? unsafeDropStash "US-flag"
    ι =? unsafeStash "US-flag" true
    unsafeGetStash "US-flag" =? Just true

  it "stores and retrieves an array" do
    ι =? unsafeDropStash "US-list"
    ι =? unsafeStash "US-list" [ 1, 2, 3 ]
    unsafeGetStash "US-list" =? Just [ 1, 2, 3 ]

  it "stores and retrieves a record" do
    ι =? unsafeDropStash "US-user"
    ι =? unsafeStash "US-user" { name: "Alice", age: 30 }
    unsafeGetStash "US-user" =? Just { name: "Alice", age: 30 }

  it "overwrites existing value" do
    ι =? unsafeDropStash "US-key"
    ι =? unsafeStash "US-key" "first"
    ι =? unsafeStash "US-key" "second"
    unsafeGetStash "US-key" =? Just "second"

  it "returns Nothing for non-existent key" do
    ι =? unsafeDropStash "US-nonexistent"
    (unsafeGetStash "US-nonexistent" :: Maybe String) =? Nothing

  it "handles multiple keys independently" do
    ι =? unsafeDropStash "US-key1"
    ι =? unsafeDropStash "US-key2"
    ι =? unsafeDropStash "US-key3"
    ι =? unsafeStash "US-key1" "value1"
    ι =? unsafeStash "US-key2" "value2"
    ι =? unsafeStash "US-key3" "value3"
    unsafeGetStash "US-key1" =? Just "value1"
    unsafeGetStash "US-key2" =? Just "value2"
    unsafeGetStash "US-key3" =? Just "value3"
