module Infra.Projection.Postgres.Finder.Test.Test where

import Proem

import Infra.Projection.Postgres.Finder.Test.Integration.Test as Integration
import Effect.Aff (Aff)
import Test.Spec (SpecT)

spec :: SpecT Aff Ɩ Aff Ɩ
spec = do
  Integration.spec
