module Infra.EventStore.Postgres.Test.Integration.Test where

import Proem

import Config.InternalConfig (internalConfig)
import Control.Monad.Trans.Class (lift)
import Effect.Aff (Aff, bracket)
import Infra.Client.Postgres.Postgres as PostgreSql
import Infra.Client.Postgres.Test.Helper (createTestDbs, dropTestDbs, generateTestDbNames)
import Infra.Client.RabbitMq.RabbitMq as RabbitMq
import Infra.EventStore.Postgres.Test.Integration.Append as Append
import Infra.EventStore.Postgres.Test.Integration.Load as Load
import Infra.EventStore.Postgres.Test.Integration.TestM (runTestM)
import Test.Spec (SpecT, afterAll_, hoistSpec)

spec :: SpecT Aff Ɩ Aff Ɩ
spec = do
  rabbitMqClient <- lift $ RabbitMq.createLazyClient internalConfig.mq

  afterAll_
    (RabbitMq.closeClient rabbitMqClient) $
    hoistSpec
      identity
      ( \_ ma -> do
          dbNames <- generateTestDbNames
          let
            config = internalConfig.db
            testConfig =
              { store: config.store { database = dbNames.store, host = config.store.directHost }
              , storeLock: config.storeLock { database = dbNames.store, host = config.storeLock.directHost }
              , edge: config.edge { database = dbNames.edge, host = config.edge.directHost }
              }

          bracket
            (createTestDbs config dbNames)
            (\_ -> dropTestDbs config dbNames)
            ( \_ ->
                bracket
                  ( do
                      postgresStoreClient <- PostgreSql.createLazyClient testConfig.store
                      postgresEdgeClient <- PostgreSql.createLazyClient testConfig.edge
                      postgresStoreLockClient <- PostgreSql.createLazyClient testConfig.storeLock
                      η { postgresStoreClient, postgresEdgeClient, postgresStoreLockClient }
                  )
                  ( \{ postgresStoreClient, postgresEdgeClient, postgresStoreLockClient } -> do
                      PostgreSql.closeClient postgresStoreClient
                      PostgreSql.closeClient postgresEdgeClient
                      PostgreSql.closeClient postgresStoreLockClient
                  )
                  (\{ postgresStoreClient, postgresEdgeClient, postgresStoreLockClient } -> runTestM { postgresStoreClient, postgresEdgeClient, postgresStoreLockClient, rabbitMqClient } ma)
            )
      )
      ( do
          Append.spec
          Load.spec
      )
