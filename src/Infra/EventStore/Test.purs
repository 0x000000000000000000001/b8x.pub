module Infra.EventStore.Test where

import Proem

import Infra.EventStore.Postgres.Test.Test as Postgres
import Effect.Aff (Aff)
import Test.Spec (SpecT)

spec :: SpecT Aff Ɩ Aff Ɩ
spec = Postgres.spec
