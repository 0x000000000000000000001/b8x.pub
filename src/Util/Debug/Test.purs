module Util.Debug.Test where

import Proem

import Effect.Aff (Aff)
import Util.Debug.Stash.Stash.Test.Test as Stash
import Test.Spec (SpecT)

spec :: SpecT Aff Ɩ Aff Ɩ
spec = do
  Stash.spec
