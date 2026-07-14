module Util.Debug.Stash.Stash.Test.UnsafeGetStashAndDrop where

import Proem

import Data.Maybe (Maybe(..))
import Effect.Aff (Aff)
import Util.Debug.Stash.Stash (unsafeStash, unsafeGetDropStash, unsafeDidStash, unsafeDropStash)
import Test.Spec (SpecT, it, describe)
import Test.Util.Assert ((=?))

fullModuleName :: String
fullModuleName = "Util.Debug.Stash.Stash.Test.UnsafeGetStashAndDrop"

spec :: SpecT Aff Ɩ Aff Ɩ
spec = describe fullModuleName do

  it "returns value and removes it" do
    ι =? unsafeDropStash "UGSAD-key-1"
    ι =? unsafeStash "UGSAD-key-1" "value"
    unsafeGetDropStash "UGSAD-key-1" =? Just "value"
    unsafeDidStash "UGSAD-key-1" =? false

  it "returns Nothing for non-existent key" do
    ι =? unsafeDropStash "UGSAD-missing"
    (unsafeGetDropStash "UGSAD-missing" :: Maybe String) =? Nothing

  it "can be called multiple times on same key" do
    ι =? unsafeDropStash "UGSAD-key-2"
    ι =? unsafeStash "UGSAD-key-2" "value"
    unsafeGetDropStash "UGSAD-key-2" =? Just "value"
    (unsafeGetDropStash "UGSAD-key-2" :: Maybe String) =? Nothing

  it "does not affect other keys" do
    ι =? unsafeDropStash "UGSAD-key1-m"
    ι =? unsafeDropStash "UGSAD-key2-m"
    ι =? unsafeStash "UGSAD-key1-m" "value1"
    ι =? unsafeStash "UGSAD-key2-m" "value2"
    unsafeGetDropStash "UGSAD-key1-m" =? Just "value1"
    unsafeDidStash "UGSAD-key2-m" =? true
