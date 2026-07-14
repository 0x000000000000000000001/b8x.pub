module Infra.EventStore.Postgres.Test.Test where

import Proem

import Infra.EventStore.Postgres.Test.Integration.Test as Integration
import Effect.Aff (Aff)
import Test.Spec (SpecT)

spec :: SpecT Aff Ɩ Aff Ɩ
spec = do
  Integration.spec
