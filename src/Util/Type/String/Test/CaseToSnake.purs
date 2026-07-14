module Util.Type.String.Test.CaseToSnake where

import Proem

import Effect.Aff (Aff)
import Util.Type.String.String (caseToSnake)
import Test.Spec (SpecT, it, describe)
import Test.Util.Assert ((=?))

fullModuleName :: String
fullModuleName = "Util.Type.String.Test.CaseToSnake"

spec :: SpecT Aff Ɩ Aff Ɩ
spec = describe fullModuleName do
  it "converts to snake_case" do
    caseToSnake "Hello World" =? "hello_world"
    caseToSnake "helloWorld" =? "hello_world"
    caseToSnake "hello-world" =? "hello_world"
    caseToSnake "" =? ""
