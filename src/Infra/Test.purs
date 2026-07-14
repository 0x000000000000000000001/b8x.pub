module Infra.Test where

import Proem

import Infra.EventStore.Test as EventStore
import Infra.Projection.Test as Projection
import Effect.Aff (Aff)
import Test.Spec (SpecT)

spec :: SpecT Aff Ɩ Aff Ɩ
spec = do
  EventStore.spec
  Projection.spec
