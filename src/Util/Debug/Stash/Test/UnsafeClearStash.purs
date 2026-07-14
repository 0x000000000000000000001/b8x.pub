module Util.Debug.Stash.Stash.Test.UnsafeClearStash where

import Proem

import Effect.Aff (Aff)
import Util.Debug.Stash.Stash (unsafeStash, unsafeDidStash, unsafeClearStash)
import Test.Spec (SpecT, it, describe)
import Test.Util.Assert ((=?))

fullModuleName :: String
fullModuleName = "Util.Debug.Stash.Stash.Test.UnsafeClearStash"

spec :: SpecT Aff Ɩ Aff Ɩ
spec = describe fullModuleName do

  it "removes all keys" do
    ι =? unsafeClearStash ι
    ι =? unsafeStash "key1" "value1"
    ι =? unsafeStash "key2" "value2"
    ι =? unsafeStash "key3" "value3"
    ι =? unsafeClearStash ι
    unsafeDidStash "key1" =? false
    unsafeDidStash "key2" =? false
    unsafeDidStash "key3" =? false

  it "can be called on empty stash" do
    ι =? unsafeClearStash ι
    ι =? unsafeClearStash ι
    unsafeDidStash "anything" =? false

  it "allows adding after clear" do
    ι =? unsafeClearStash ι
    ι =? unsafeStash "before" "value"
    ι =? unsafeClearStash ι
    ι =? unsafeStash "after" "new"
    unsafeDidStash "before" =? false
    unsafeDidStash "after" =? true
