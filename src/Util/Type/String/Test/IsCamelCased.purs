module Util.Type.String.Test.IsCamelCased where

import Proem

import Effect.Aff (Aff)
import Util.Type.String.String (isCamelCased)
import Test.Spec (SpecT, it, describe)
import Test.Util.Assert ((=?))

fullModuleName :: String
fullModuleName = "Util.Type.String.Test.IsCamelCased"

spec :: SpecT Aff Ɩ Aff Ɩ
spec = describe fullModuleName do
  it "detects camelCase" do
    isCamelCased "helloWorld" =? true
    isCamelCased "hello" =? true
    isCamelCased "HelloWorld" =? false
    isCamelCased "hello-world" =? false
