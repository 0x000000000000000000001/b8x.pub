module Infra.EventStore.Postgres.Test.Integration.Load where

import Proem hiding (append, (&&), (||))

import Core.Event.Event (Event(..))
import Core.Event.EventStore (appendEvents, loadEvents)
import Core.Event.Filter (Filter(..), by, false_, byType)
import Core.Event.UserEmailChanged.UserEmailChanged (UserEmailChanged)
import Core.Event.UserRegistered.UserRegistered (UserRegistered)
import Infra.EventStore.Postgres.Test.Integration.TestM (TestM)
import Data.Array (length, (!!))
import Data.Maybe (Maybe(..))
import Effect.Aff (Aff)
import Util.Type.Random (random)
import Test.Spec (SpecT, it, describe)
import Test.Spec.Assertions (fail)
import Core.Mod.Trace.Trace (Trace)
import Core.Mod.Id.Id as Id
import Test.Util.Assert ((=?))

dummyTrace :: Trace
dummyTrace = { run: Id.unsafeFromString "00000000000000000000000000", append: Nothing, cause: Nothing, overriddenAt: Nothing }

fullModuleName :: String
fullModuleName = "Infra.EventStore.Postgres.Test.Integration.Load"

spec :: SpecT TestM Ɩ Aff Ɩ
spec = describe fullModuleName do
  it "loads events by type" do
    id <- random
    email <- random
    let event = UserRegistered { id, email }

    ø $ appendEvents dummyTrace [ event ] { filter: Nothing, expectedMaxSequenceNumber: Nothing, requiresStrictConcurrencyProtection: true}

    loadedEvents <- loadEvents $ And (byType @UserRegistered) (by @UserRegistered @"id" id)

    length loadedEvents =? 1

    case loadedEvents !! 0 of
      Just loadedEvent -> case loadedEvent.event of
        UserRegistered { id: loadedId } -> loadedId =? id
        _ -> ʌ' $ fail "Expected UserRegistered event"
      Nothing -> ʌ' $ fail "Expected to load exactly one event"

  it "loads events by string field" do
    id <- random
    email <- random
    let event = UserRegistered { id, email }

    ø $ appendEvents dummyTrace [ event ] { filter: Nothing, expectedMaxSequenceNumber: Nothing, requiresStrictConcurrencyProtection: true}

    loadedEvents <- loadEvents $ by @UserRegistered @"id" id

    length loadedEvents =? 1

  it "returns empty array when no events match filter" do
    id <- random
    loadedEvents <- loadEvents $ by @UserRegistered @"id" id

    length loadedEvents =? 0

  it "loads events by specific id" do
    id <- random
    email <- random
    let event = UserRegistered { id, email }

    ø $ appendEvents dummyTrace [ event ] { filter: Nothing, expectedMaxSequenceNumber: Nothing, requiresStrictConcurrencyProtection: true}

    loadedEvents <- loadEvents $ by @UserRegistered @"id" id

    length loadedEvents =? 1

  it "returns empty array with ByEverything filter" do
    loadedEvents <- loadEvents false_

    length loadedEvents =? 0

  it "loads events with And filter" do
    id <- random
    email <- random
    let event = UserRegistered { id, email }

    ø $ appendEvents dummyTrace [ event ] { filter: Nothing, expectedMaxSequenceNumber: Nothing, requiresStrictConcurrencyProtection: true}

    loadedEvents <- loadEvents $ And (byType @UserRegistered) (by @UserRegistered @"id" id)

    length loadedEvents =? 1

    case loadedEvents !! 0 of
      Just loadedEvent -> case loadedEvent.event of
        UserRegistered _ -> η ι
        _ -> ʌ' $ fail "Expected UserRegistered event"
      Nothing -> ʌ' $ fail "Expected to load exactly one event"

  it "loads events with Or filter" do
    id1 <- random
    id2 <- random
    email1 <- random
    email2 <- random
    let
      events =
        [ UserRegistered { id: id1, email: email1 }
        , UserRegistered { id: id2, email: email2 }
        ]

    ø $ appendEvents dummyTrace events { filter: Nothing, expectedMaxSequenceNumber: Nothing, requiresStrictConcurrencyProtection: true}

    loadedEvents <- loadEvents $ Or (by @UserRegistered @"id" id1) (by @UserRegistered @"id" id2)

    length loadedEvents =? 2

  it "loads events in correct order (by id ASC)" do
    id <- random
    email <- random

    let
      events =
        [ UserRegistered { id, email }
        , UserEmailChanged { user: id, email }
        ]

    ø $ appendEvents dummyTrace events { filter: Nothing, expectedMaxSequenceNumber: Nothing, requiresStrictConcurrencyProtection: true}

    loadedEvents <- loadEvents $ Or (by @UserRegistered @"id" id) (by @UserEmailChanged @"user" id)

    length loadedEvents =? 2

    -- Verify order: UserRegistered should come before UserEmailChanged
    case loadedEvents !! 0, loadedEvents !! 1 of
      Just first, Just second -> do
        case first.event of
          UserRegistered _ -> η ι
          _ -> ʌ' $ fail "Expected first event to be UserRegistered"
        case second.event of
          UserEmailChanged _ -> η ι
          _ -> ʌ' $ fail "Expected second event to be UserEmailChanged"
      _, _ -> ʌ' $ fail "Expected exactly 2 events"
