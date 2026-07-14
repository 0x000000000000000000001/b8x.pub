module Util.Debug.Stash.Stash.Test.UnsafeDropStash where

import Proem

import Data.Maybe (Maybe(..))
import Effect.Aff (Aff)
import Util.Debug.Stash.Stash (unsafeStash, unsafeGetStash, unsafeDropStash, unsafeDidStash)
import Test.Spec (SpecT, it, describe)
import Test.Util.Assert ((=?))

fullModuleName :: String
fullModuleName = "Util.Debug.Stash.Stash.Test.UnsafeDropStash"

spec :: SpecT Aff Ɩ Aff Ɩ
spec = describe fullModuleName do

  it "removes existing key" do
    ι =? unsafeDropStash "UDrS-key-1"
    ι =? unsafeStash "UDrS-key-1" "value"
    ι =? unsafeDropStash "UDrS-key-1"
    (unsafeGetStash "UDrS-key-1" :: Maybe String) =? Nothing

  it "does not affect other keys" do
    ι =? unsafeDropStash "UDrS-key1-m"
    ι =? unsafeDropStash "UDrS-key2-m"
    ι =? unsafeStash "UDrS-key1-m" "value1"
    ι =? unsafeStash "UDrS-key2-m" "value2"
    ι =? unsafeDropStash "UDrS-key1-m"
    unsafeGetStash "UDrS-key2-m" =? Just "value2"

  it "handles dropping non-existent key" do
    ι =? unsafeDropStash "UDrS-nonexistent"
    ι =? unsafeDropStash "UDrS-nonexistent"
    unsafeDidStash "UDrS-nonexistent" =? false

  it "can drop and re-add key" do
    ι =? unsafeDropStash "UDrS-key-2"
    ι =? unsafeStash "UDrS-key-2" "first"
    ι =? unsafeDropStash "UDrS-key-2"
    ι =? unsafeStash "UDrS-key-2" "second"
    unsafeGetStash "UDrS-key-2" =? Just "second"
