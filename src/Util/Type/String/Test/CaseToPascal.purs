module Util.Type.String.Test.CaseToPascal where

import Proem

import Effect.Aff (Aff)
import Util.Type.String.String (caseToPascal)
import Test.Spec (SpecT, it, describe)
import Test.Util.Assert ((=?))

fullModuleName :: String
fullModuleName = "Util.Type.String.Test.CaseToPascal"

spec :: SpecT Aff Ɩ Aff Ɩ
spec = describe fullModuleName do
  it "converts to PascalCase" do
    caseToPascal "hello world" =? "HelloWorld"
    caseToPascal "hello-world" =? "HelloWorld"
    caseToPascal "hello_world" =? "HelloWorld"
    caseToPascal "Hello World" =? "HelloWorld"
    caseToPascal "" =? ""
