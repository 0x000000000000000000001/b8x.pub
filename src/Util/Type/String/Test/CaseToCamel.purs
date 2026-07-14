module Util.Type.String.Test.CaseToCamel where

import Proem

import Effect.Aff (Aff)
import Util.Type.String.String (caseToCamel)
import Test.Spec (SpecT, it, describe)
import Test.Util.Assert ((=?))

fullModuleName :: String
fullModuleName = "Util.Type.String.Test.CaseToCamel"

spec :: SpecT Aff Ɩ Aff Ɩ
spec = describe fullModuleName do
  it "converts to camelCase" do
    caseToCamel "hello world" =? "helloWorld"
    caseToCamel "Hello World" =? "helloWorld"
    caseToCamel "hello-world" =? "helloWorld"
    caseToCamel "" =? ""
