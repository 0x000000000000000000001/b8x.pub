module Util.Type.String.Test.CaseToTrain where

import Proem

import Effect.Aff (Aff)
import Util.Type.String.String (caseToTrain)
import Test.Spec (SpecT, it, describe)
import Test.Util.Assert ((=?))

fullModuleName :: String
fullModuleName = "Util.Type.String.Test.CaseToTrain"

spec :: SpecT Aff Ɩ Aff Ɩ
spec = describe fullModuleName do
  it "converts to TRAIN-CASE" do
    caseToTrain "hello world" =? "HELLO-WORLD"
    caseToTrain "helloWorld" =? "HELLO-WORLD"
    caseToTrain "hello_world" =? "HELLO-WORLD"
    caseToTrain "" =? ""
