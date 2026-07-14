module Util.Debug.Stash.Stash.Test.UnsafeGetStashWithDefault where

import Proem

import Effect.Aff (Aff)
import Util.Debug.Stash.Stash (unsafeStash, unsafeGetStashWithDefault, unsafeDropStash)
import Test.Spec (SpecT, it, describe)
import Test.Util.Assert ((=?))

fullModuleName :: String
fullModuleName = "Util.Debug.Stash.Stash.Test.UnsafeGetStashWithDefault"

spec :: SpecT Aff Ɩ Aff Ɩ
spec = describe fullModuleName do

  it "returns stored value when key exists" do
    ι =? unsafeDropStash "UGSWD-key"
    ι =? unsafeStash "UGSWD-key" "stored"
    unsafeGetStashWithDefault "UGSWD-key" "default" =? "stored"

  it "returns default value when key does not exist" do
    ι =? unsafeDropStash "UGSWD-missing"
    unsafeGetStashWithDefault "UGSWD-missing" "default" =? "default"

  it "returns default for integer" do
    ι =? unsafeDropStash "UGSWD-counter-1"
    unsafeGetStashWithDefault "UGSWD-counter-1" 0 =? 0

  it "returns stored integer" do
    ι =? unsafeDropStash "UGSWD-counter-2"
    ι =? unsafeStash "UGSWD-counter-2" 42
    unsafeGetStashWithDefault "UGSWD-counter-2" 0 =? 42

  it "returns default for boolean" do
    ι =? unsafeDropStash "UGSWD-flag-1"
    unsafeGetStashWithDefault "UGSWD-flag-1" false =? false

  it "returns stored boolean" do
    ι =? unsafeDropStash "UGSWD-flag-2"
    ι =? unsafeStash "UGSWD-flag-2" true
    unsafeGetStashWithDefault "UGSWD-flag-2" false =? true

  it "returns default for array" do
    ι =? unsafeDropStash "UGSWD-list-1"
    unsafeGetStashWithDefault "UGSWD-list-1" [ 1, 2, 3 ] =? [ 1, 2, 3 ]

  it "returns stored array" do
    ι =? unsafeDropStash "UGSWD-list-2"
    ι =? unsafeStash "UGSWD-list-2" [ 4, 5, 6 ]
    unsafeGetStashWithDefault "UGSWD-list-2" [ 1, 2, 3 ] =? [ 4, 5, 6 ]
