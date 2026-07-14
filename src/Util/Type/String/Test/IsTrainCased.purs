module Util.Type.String.Test.IsTrainCased where

import Proem

import Effect.Aff (Aff)
import Util.Type.String.String (isTrainCased)
import Test.Spec (SpecT, it, describe)
import Test.Util.Assert ((=?))

fullModuleName :: String
fullModuleName = "Util.Type.String.Test.IsTrainCased"

spec :: SpecT Aff Ɩ Aff Ɩ
spec = describe fullModuleName do
  it "detects TRAIN-CASE" do
    isTrainCased "HELLO-WORLD" =? true
    isTrainCased "HELLO" =? true
    isTrainCased "Hello-World" =? false
    isTrainCased "hello-world" =? false
