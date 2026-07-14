module Util.Type.String.Test.CaseToConstant where

import Proem

import Effect.Aff (Aff)
import Util.Type.String.String (caseToConstant)
import Test.Spec (SpecT, it, describe)
import Test.Util.Assert ((=?))

fullModuleName :: String
fullModuleName = "Util.Type.String.Test.CaseToConstant"

spec :: SpecT Aff Ɩ Aff Ɩ
spec = describe fullModuleName do
  it "converts to CONSTANT_CASE" do
    caseToConstant "hello world" =? "HELLO_WORLD"
    caseToConstant "helloWorld" =? "HELLO_WORLD"
    caseToConstant "hello-world" =? "HELLO_WORLD"
    caseToConstant "" =? ""
