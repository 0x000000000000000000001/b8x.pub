module Util.Type.String.Test.IsKebabCased where

import Proem

import Effect.Aff (Aff)
import Util.Type.String.String (isKebabCased)
import Test.Spec (SpecT, it, describe)
import Test.Util.Assert ((=?))

fullModuleName :: String
fullModuleName = "Util.Type.String.Test.IsKebabCased"

spec :: SpecT Aff Ɩ Aff Ɩ
spec = describe fullModuleName do
  it "detects kebab-case" do
    isKebabCased "hello-world" =? true
    isKebabCased "hello" =? true
    isKebabCased "helloWorld" =? false
    isKebabCased "hello_world" =? false
