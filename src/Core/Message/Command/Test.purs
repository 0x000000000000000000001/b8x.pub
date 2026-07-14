module Core.Message.Command.Test where

import Proem

import Core.Message.Command.Handle.Test.Test as Handle
import Effect.Aff (Aff)
import Test.Spec (SpecT)

spec :: SpecT Aff Ɩ Aff Ɩ
spec = do
  Handle.spec
