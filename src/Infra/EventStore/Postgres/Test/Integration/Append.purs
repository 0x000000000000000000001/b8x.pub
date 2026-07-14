module Infra.EventStore.Postgres.Test.Integration.Append where

import Proem hiding (append, (&&), (||))

import Core.Event.Event (Event(..))
import Core.Event.EventStore (appendEvents, loadEvents)
import Core.Event.Filter (Filter(..), by, byType)
import Core.Event.UserEmailChanged.UserEmailChanged (UserEmailChanged)
import Core.Event.UserRegistered.Payload as UserRegistered
import Core.Event.UserRegistered.UserRegistered (UserRegistered)
import Infra.EventStore.Postgres.Test.Integration.TestM (TestM)
import Data.Array (length)
import Data.Maybe (Maybe(..))
import Effect.Aff (Aff)
import Util.Type.Random (random)
import Test.Spec (SpecT, it, describe)
import Core.Mod.Trace.Trace (Trace)
import Core.Mod.Id.Id as Id
import Test.Util.Assert ((=?))

dummyTrace :: Trace
dummyTrace = { run: Id.unsafeFromString "00000000000000000000000000", append: Nothing, cause: Nothing, overriddenAt: Nothing }

fullModuleName :: String
fullModuleName = "Infra.EventStore.Postgres.Test.Integration.Append"

spec :: SpecT TestM Ɩ Aff Ɩ
spec = describe fullModuleName do
  it "appends single event to database" do
    event <- UserRegistered <$> random @UserRegistered.Payload

    ø $ appendEvents dummyTrace [ event ] { filter: Nothing, expectedMaxSequenceNumber: Nothing, requiresStrictConcurrencyProtection: true}

  it "appends multiple events with same append ID" do
    p1 <- random @UserRegistered.Payload
    p2 <- random @UserRegistered.Payload
    let events = [ UserRegistered p1, UserRegistered p2 ]

    ø $ appendEvents dummyTrace events { filter: Nothing, expectedMaxSequenceNumber: Nothing, requiresStrictConcurrencyProtection: true}

    loadedEvents <- loadEvents $ Or (by @UserRegistered @"id" p1.id) (by @UserRegistered @"id" p2.id)

    length loadedEvents =? 2

  it "returns true when appending empty array" do
    ø $ appendEvents dummyTrace [] { filter: Nothing, expectedMaxSequenceNumber: Nothing, requiresStrictConcurrencyProtection: true}

  it "can append and then load the same event" do
    id <- random
    email <- random

    let event = UserRegistered { id, email }

    ø $ appendEvents dummyTrace [ event ] { filter: Nothing, expectedMaxSequenceNumber: Nothing, requiresStrictConcurrencyProtection: true}

    loadedEvents <- loadEvents $ by @UserRegistered @"id" id

    length loadedEvents =? 1

  it "appends events of different types" do
    id <- random
    email <- random

    let
      events =
        [ UserRegistered { id, email }
        , UserEmailChanged { user: id, email }
        ]

    ø $ appendEvents dummyTrace events { filter: Nothing, expectedMaxSequenceNumber: Nothing, requiresStrictConcurrencyProtection: true}

    registeredEvents <- loadEvents $ And (byType @UserRegistered) (by @UserRegistered @"id" id)

    emailChangedEvents <- loadEvents $ And (byType @UserEmailChanged) (by @UserEmailChanged @"user" id)

    length registeredEvents =? 1
    length emailChangedEvents =? 1
