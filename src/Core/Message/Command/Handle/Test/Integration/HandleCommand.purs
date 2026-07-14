module Core.Message.Command.Handle.Test.Integration.HandleCommand where

import Proem hiding (append)

import Control.Parallel (parTraverse)
import Core.Feat.Membership.Message.Command.ChangeUserEmail.Command (ChangeUserEmail)
import Core.Feat.Membership.Message.Command.ChangeUserEmail.Decide (decide)
import Core.Feat.Membership.Message.Command.ChangeUserEmail.Filter (filter)
import Core.Feat.Membership.Message.Command.ChangeUserEmail.Payload (Fields, Payload)
import Core.Feat.Membership.Message.Command.ChangeUserEmail.Play (play)
import Core.Feat.Membership.Message.Command.ChangeUserEmail.Result (Result, toResult)
import Core.Feat.Membership.Message.Command.ChangeUserEmail.State (State, initialState)
import Core.Feat.Membership.Message.Command.RegisterUser.Command (RegisterUser(..))
import Core.Message.Command.Command (class IsCommand, class IsProtectedAgainstConcurrency, ConcurrencyPriority(..), defaultCheckLoadedEvents, defaultHandle, description)
import Core.Message.Command.Handle.Handle (handleCommand', handleCommand_)
import Core.Message.Command.Handle.Test.Integration.TestM (TestM, runTestM)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Array (length, mapMaybe, replicate)
import Data.Array as Array
import Data.Either (hush, isLeft)
import Data.Foldable (sum)
import Data.Generic.Rep (class Generic)
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)
import Effect.Aff (Aff, try)
import Infra.Client.Postgres.Postgres (readerPostgresEdgeClient', readerPostgresStoreClient', readerPostgresStoreLockClient')
import Infra.Client.RabbitMq.RabbitMq (readerRabbitMqClient')
import Run.Reader (askAt)
import Test.Spec (SpecT, describe, it)
import Test.Util.Assert ((=?), (>?))
import Util.Type.Random (class Random, random)
import Util.Type.Type (class Reflect, reflectConstructorName)

fullModuleName :: String
fullModuleName = "Core.Message.Command.Handle.Test.Integration.HandleCommand"

spec :: SpecT TestM Ɩ Aff Ɩ
spec = describe fullModuleName do
  it "should execute a single command" do
    cmd <- random @RegisterUser
    let id = case cmd of RegisterUser payload -> payload.id
    handleCommand_ false cmd

    email <- random
    res <- handleCommand' false $ ChangeUserEmail' { user: id, email }

    res.tries =? 1

  it "should retry commands on concurrency conflict until it succeeds" do
    cmd <- random @RegisterUser

    let id = case cmd of RegisterUser payload -> payload.id

    handleCommand_ false cmd

    let numCommands = 5

    postgresStoreClient <- askAt readerPostgresStoreClient'
    postgresEdgeClient <- askAt readerPostgresEdgeClient'
    postgresStoreLockClient <- askAt readerPostgresStoreLockClient'
    rabbitMqClient <- askAt readerRabbitMqClient'

    results <- ʌ' $ parTraverse
      ( κ $ try $ runTestM { postgresStoreClient, postgresEdgeClient, postgresStoreLockClient, rabbitMqClient } do
          email <- random
          handleCommand' false $ ChangeUserEmail' { user: id, email }
      )
      (replicate numCommands ι)

    let
      successes = mapMaybe hush results
      totalTries = sum $ successes <#> _.tries
      failures = Array.filter isLeft results

    length successes =? numCommands
    totalTries >? length successes
    length failures =? 0

  it "should retry commands on concurrency conflict and stop when it is too much" do
    cmd <- random @RegisterUser

    let id = case cmd of RegisterUser payload -> payload.id

    handleCommand_ false cmd

    let numCommands = 5

    postgresStoreClient <- askAt readerPostgresStoreClient'
    postgresEdgeClient <- askAt readerPostgresEdgeClient'
    postgresStoreLockClient <- askAt readerPostgresStoreLockClient'
    rabbitMqClient <- askAt readerRabbitMqClient'

    results <- ʌ' $ parTraverse
      ( κ $ try $ runTestM { postgresStoreClient, postgresEdgeClient, postgresStoreLockClient, rabbitMqClient } do
          email <- random
          handleCommand' false $ ChangeUserEmail'' { user: id, email }
      )
      (replicate numCommands ι)

    let
      successes = mapMaybe hush results
      totalTries = sum $ successes <#> _.tries
      failures = Array.filter isLeft results

    length successes >? 0
    totalTries >? length successes
    length failures >? 0

newtype ChangeUserEmail' = ChangeUserEmail' Payload

derive instance Newtype ChangeUserEmail' _
derive instance Generic ChangeUserEmail' _
derive newtype instance ReadForeign ChangeUserEmail'
derive newtype instance WriteForeign ChangeUserEmail'
derive newtype instance Random ChangeUserEmail'

instance Reflect ChangeUserEmail' where
  reflectName = reflectConstructorName @ChangeUserEmail

instance IsProtectedAgainstConcurrency ChangeUserEmail' where
  priority = Safe
  maxRetries = 30
  baseRetryDelayMs = 50

newtype ChangeUserEmail'' = ChangeUserEmail'' Payload

derive instance Newtype ChangeUserEmail'' _
derive instance Generic ChangeUserEmail'' _
derive newtype instance ReadForeign ChangeUserEmail''
derive newtype instance WriteForeign ChangeUserEmail''
derive newtype instance Random ChangeUserEmail''

instance Reflect ChangeUserEmail'' where
  reflectName = reflectConstructorName @ChangeUserEmail''

instance IsProtectedAgainstConcurrency ChangeUserEmail'' where
  priority = Safe
  maxRetries = 1
  baseRetryDelayMs = 1

instance
  IsCommand
    ChangeUserEmail'
    State
    Fields
    Payload
    Result
  where
  description = description @ChangeUserEmail

  handle = defaultHandle @ChangeUserEmail' (Just filter) defaultCheckLoadedEvents initialState play decide toResult

instance
  IsCommand
    ChangeUserEmail''
    State
    Fields
    Payload
    Result
  where
  description = description @ChangeUserEmail

  handle = defaultHandle @ChangeUserEmail'' (Just filter) defaultCheckLoadedEvents initialState play decide toResult
