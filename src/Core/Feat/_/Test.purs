module Core.Feat.Test where

import Proem

import Core.Message.Test as Message
import Effect.Aff (Aff)
import Test.Spec (SpecT)

spec :: SpecT Aff Ɩ Aff Ɩ
spec = do
  Message.spec
