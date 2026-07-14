module Core.Test where

import Proem

import Core.Feat.Test as Feat
import Effect.Aff (Aff)
import Test.Spec (SpecT)

spec :: SpecT Aff Ɩ Aff Ɩ
spec = do
  Feat.spec
