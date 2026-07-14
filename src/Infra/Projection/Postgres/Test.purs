module Infra.Projection.Postgres.Test where

import Proem

import Infra.Projection.Postgres.Finder.Test.Test as Finder
import Effect.Aff (Aff)
import Test.Spec (SpecT)

spec :: SpecT Aff Ɩ Aff Ɩ
spec = do
  Finder.spec
