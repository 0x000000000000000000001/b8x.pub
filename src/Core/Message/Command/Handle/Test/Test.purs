module Core.Message.Command.Handle.Test.Test where

import Proem

import Core.Message.Command.Handle.Test.Integration.Test as Integration
import Effect.Aff (Aff)
import Test.Spec (SpecT)

spec :: SpecT Aff Ɩ Aff Ɩ
spec = do
  Integration.spec
