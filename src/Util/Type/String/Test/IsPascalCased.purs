module Util.Type.String.Test.IsPascalCased where

import Proem

import Effect.Aff (Aff)
import Util.Type.String.String (isPascalCased)
import Test.Spec (SpecT, it, describe)
import Test.Util.Assert ((=?))

fullModuleName :: String
fullModuleName = "Util.Type.String.Test.IsPascalCased"

spec :: SpecT Aff Ɩ Aff Ɩ
spec = describe fullModuleName do
  it "detects PascalCase" do
    isPascalCased "HelloWorld" =? true
    isPascalCased "Hello" =? true
    isPascalCased "helloWorld" =? false
    isPascalCased "hello_world" =? false
