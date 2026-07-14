module Util.Type.String.Test.IsConstantCased where

import Proem

import Effect.Aff (Aff)
import Util.Type.String.String (isConstantCased)
import Test.Spec (SpecT, it, describe)
import Test.Util.Assert ((=?))

fullModuleName :: String
fullModuleName = "Util.Type.String.Test.IsConstantCased"

spec :: SpecT Aff Ɩ Aff Ɩ
spec = describe fullModuleName do
  it "detects CONSTANT_CASE" do
    isConstantCased "HELLO_WORLD" =? true
    isConstantCased "HELLO" =? true
    isConstantCased "Hello_World" =? false
    isConstantCased "hello_world" =? false
