module Infra.Projection.Test where

import Proem

import Infra.Projection.Postgres.Test as Postgres
import Effect.Aff (Aff)
import Test.Spec (SpecT)

spec :: SpecT Aff Ɩ Aff Ɩ
spec = do
  Postgres.spec
