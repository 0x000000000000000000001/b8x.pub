module Util.Debug.Stash.Stash.Test.UnsafeDidStash where

import Proem

import Effect.Aff (Aff)
import Util.Debug.Stash.Stash (unsafeStash, unsafeDidStash, unsafeDropStash)
import Test.Spec (SpecT, it, describe)
import Test.Util.Assert ((=?))

fullModuleName :: String
fullModuleName = "Util.Debug.Stash.Stash.Test.UnsafeDidStash"

spec :: SpecT Aff Ɩ Aff Ɩ
spec = describe fullModuleName do

  it "returns false for non-existent key" do
    ι =? unsafeDropStash "UDS-missing"
    unsafeDidStash "UDS-missing" =? false

  it "returns true for existing key" do
    ι =? unsafeDropStash "UDS-key-1"
    ι =? unsafeStash "UDS-key-1" "value"
    unsafeDidStash "UDS-key-1" =? true

  it "returns false after dropping key" do
    ι =? unsafeDropStash "UDS-key-2"
    ι =? unsafeStash "UDS-key-2" "value"
    ι =? unsafeDropStash "UDS-key-2"
    unsafeDidStash "UDS-key-2" =? false

  it "returns true after storing value" do
    ι =? unsafeDropStash "UDS-test"
    ι =? unsafeStash "UDS-test" 123
    unsafeDidStash "UDS-test" =? true

  it "handles multiple keys correctly" do
    ι =? unsafeDropStash "UDS-key1-m"
    ι =? unsafeDropStash "UDS-key2-m"
    ι =? unsafeDropStash "UDS-key3-m"
    ι =? unsafeStash "UDS-key1-m" "a"
    ι =? unsafeStash "UDS-key2-m" "b"
    unsafeDidStash "UDS-key1-m" =? true
    unsafeDidStash "UDS-key2-m" =? true
    unsafeDidStash "UDS-key3-m" =? false
