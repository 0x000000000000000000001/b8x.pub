module Util.Debug.Stash.Stash.Test.UnsafePushToStash where

import Proem

import Data.Maybe (Maybe(..))
import Effect.Aff (Aff)
import Util.Debug.Stash.Stash (unsafePushToStash, unsafeGetStash, unsafeDropStash)
import Test.Spec (SpecT, it, describe)
import Test.Util.Assert ((=?))

fullModuleName :: String
fullModuleName = "Util.Debug.Stash.Stash.Test.UnsafePushToStash"

spec :: SpecT Aff Ɩ Aff Ɩ
spec = describe fullModuleName do

  it "creates array with first element" do
    ι =? unsafeDropStash "UPTS-list-1"
    ι =? unsafePushToStash "UPTS-list-1" "first"
    (unsafeGetStash "UPTS-list-1" :: Maybe (Array String)) =? Just [ "first" ]

  it "appends to existing array" do
    ι =? unsafeDropStash "UPTS-list-2"
    ι =? unsafePushToStash "UPTS-list-2" "first"
    ι =? unsafePushToStash "UPTS-list-2" "second"
    ι =? unsafePushToStash "UPTS-list-2" "third"
    (unsafeGetStash "UPTS-list-2" :: Maybe (Array String)) =? Just [ "first", "second", "third" ]

  it "handles integers" do
    ι =? unsafeDropStash "UPTS-numbers"
    ι =? unsafePushToStash "UPTS-numbers" 1
    ι =? unsafePushToStash "UPTS-numbers" 2
    ι =? unsafePushToStash "UPTS-numbers" 3
    (unsafeGetStash "UPTS-numbers" :: Maybe (Array Int)) =? Just [ 1, 2, 3 ]

  it "handles multiple independent arrays" do
    ι =? unsafeDropStash "UPTS-list1"
    ι =? unsafeDropStash "UPTS-list2"
    ι =? unsafePushToStash "UPTS-list1" "a"
    ι =? unsafePushToStash "UPTS-list2" "x"
    ι =? unsafePushToStash "UPTS-list1" "b"
    ι =? unsafePushToStash "UPTS-list2" "y"
    (unsafeGetStash "UPTS-list1" :: Maybe (Array String)) =? Just [ "a", "b" ]
    (unsafeGetStash "UPTS-list2" :: Maybe (Array String)) =? Just [ "x", "y" ]

  it "handles records" do
    ι =? unsafeDropStash "UPTS-users"
    ι =? unsafePushToStash "UPTS-users" { name: "Alice", age: 30 }
    ι =? unsafePushToStash "UPTS-users" { name: "Bob", age: 25 }
    (unsafeGetStash "UPTS-users" :: Maybe (Array { name :: String, age :: Int })) =? Just [ { name: "Alice", age: 30 }, { name: "Bob", age: 25 } ]
