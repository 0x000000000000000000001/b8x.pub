module Util.Type.String.Test.IsHeaderCased where

import Proem

import Effect.Aff (Aff)
import Util.Type.String.String (isHeaderCased)
import Test.Spec (SpecT, it, describe)
import Test.Util.Assert ((=?))

fullModuleName :: String
fullModuleName = "Util.Type.String.Test.IsHeaderCased"

spec :: SpecT Aff Ɩ Aff Ɩ
spec = describe fullModuleName do
  it "detects Header-Case" do
    isHeaderCased "Hello-World" =? true
    isHeaderCased "Hello" =? true
    isHeaderCased "hello-world" =? false
    isHeaderCased "Hello_World" =? false
