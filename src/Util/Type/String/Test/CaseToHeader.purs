module Util.Type.String.Test.CaseToHeader where

import Proem

import Effect.Aff (Aff)
import Util.Type.String.String (caseToHeader)
import Test.Spec (SpecT, it, describe)
import Test.Util.Assert ((=?))

fullModuleName :: String
fullModuleName = "Util.Type.String.Test.CaseToHeader"

spec :: SpecT Aff Ɩ Aff Ɩ
spec = describe fullModuleName do
  it "converts to Header-Case" do
    caseToHeader "hello world" =? "Hello-World"
    caseToHeader "helloWorld" =? "Hello-World"
    caseToHeader "hello_world" =? "Hello-World"
    caseToHeader "" =? ""
