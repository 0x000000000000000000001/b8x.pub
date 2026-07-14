module Util.Debug.Stash.Stash.Test.UnsafeIncrementStash where

import Proem

import Data.Maybe (Maybe(..))
import Effect.Aff (Aff)
import Util.Debug.Stash.Stash (unsafeIncrementStash, unsafeGetStash, unsafeDropStash)
import Test.Spec (SpecT, it, describe)
import Test.Util.Assert ((=?))

fullModuleName :: String
fullModuleName = "Util.Debug.Stash.Stash.Test.UnsafeIncrementStash"

spec :: SpecT Aff Ɩ Aff Ɩ
spec = describe fullModuleName do

  it "initializes to 1 on first increment" do
    ι =? unsafeDropStash "UIS-counter-1"
    ι =? unsafeIncrementStash "UIS-counter-1"
    unsafeGetStash "UIS-counter-1" =? Just 1

  it "increments existing value" do
    ι =? unsafeDropStash "UIS-counter-2"
    ι =? unsafeIncrementStash "UIS-counter-2"
    ι =? unsafeIncrementStash "UIS-counter-2"
    ι =? unsafeIncrementStash "UIS-counter-2"
    unsafeGetStash "UIS-counter-2" =? Just 3

  it "handles multiple counters independently" do
    ι =? unsafeDropStash "UIS-counter1"
    ι =? unsafeDropStash "UIS-counter2"
    ι =? unsafeIncrementStash "UIS-counter1"
    ι =? unsafeIncrementStash "UIS-counter1"
    ι =? unsafeIncrementStash "UIS-counter2"
    unsafeGetStash "UIS-counter1" =? Just 2
    unsafeGetStash "UIS-counter2" =? Just 1

  it "increments to large numbers" do
    ι =? unsafeDropStash "UIS-big"
    ι =? unsafeIncrementStash "UIS-big"
    ι =? unsafeIncrementStash "UIS-big"
    ι =? unsafeIncrementStash "UIS-big"
    ι =? unsafeIncrementStash "UIS-big"
    ι =? unsafeIncrementStash "UIS-big"
    ι =? unsafeIncrementStash "UIS-big"
    ι =? unsafeIncrementStash "UIS-big"
    ι =? unsafeIncrementStash "UIS-big"
    ι =? unsafeIncrementStash "UIS-big"
    ι =? unsafeIncrementStash "UIS-big"
    unsafeGetStash "UIS-big" =? Just 10
