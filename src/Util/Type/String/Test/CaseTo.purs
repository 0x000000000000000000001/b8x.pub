module Util.Type.String.Test.CaseTo where

import Proem

import Effect.Aff (Aff)
import Util.Type.String.String (Case(..), caseTo)
import Test.Spec (SpecT, it, describe)
import Test.Util.Assert ((=?))

fullModuleName :: String
fullModuleName = "Util.Type.String.Test.CaseTo"

spec :: SpecT Aff Ɩ Aff Ɩ
spec = describe fullModuleName do
  it "converts" do
    caseTo Camel "hello world" =? "helloWorld"
    caseTo Camel "Hello World" =? "helloWorld"
    caseTo Camel "hello-world" =? "helloWorld"
    caseTo Camel "" =? ""
