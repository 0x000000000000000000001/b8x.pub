module Util.Type.String.Test.IsSnakeCased where

import Proem

import Effect.Aff (Aff)
import Util.Type.String.String (isSnakeCased)
import Test.Spec (SpecT, it, describe)
import Test.Util.Assert ((=?))

fullModuleName :: String
fullModuleName = "Util.Type.String.Test.IsSnakeCased"

spec :: SpecT Aff Ɩ Aff Ɩ
spec = describe fullModuleName do
  it "detects snake_case" do
    isSnakeCased "hello_world" =? true
    isSnakeCased "hello" =? true
    isSnakeCased "helloWorld" =? false
    isSnakeCased "Hello_World" =? false
