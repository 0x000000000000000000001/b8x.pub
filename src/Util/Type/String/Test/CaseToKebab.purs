module Util.Type.String.Test.CaseToKebab where

import Proem

import Effect.Aff (Aff)
import Util.Type.String.String (caseToKebab)
import Test.Spec (SpecT, it, describe)
import Test.Util.Assert ((=?))

fullModuleName :: String
fullModuleName = "Util.Type.String.Test.CaseToKebab"

spec :: SpecT Aff Ɩ Aff Ɩ
spec = describe fullModuleName do
  it "converts to kebab-case" do
    caseToKebab "Hello World" =? "hello-world"
    caseToKebab "helloWorld" =? "hello-world"
    caseToKebab "hello_world" =? "hello-world"
    caseToKebab "" =? ""
