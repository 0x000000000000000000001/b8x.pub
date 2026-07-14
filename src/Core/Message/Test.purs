module Core.Message.Test where

import Proem

import Core.Message.Command.Test as Command
import Effect.Aff (Aff)
import Test.Spec (SpecT)

spec :: SpecT Aff Ɩ Aff Ɩ
spec = do
  Command.spec
