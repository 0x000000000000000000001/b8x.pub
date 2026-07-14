module Infra.Client.Postgres.Test.Helper where

import Proem

import Config.InternalConfig (DbSubConfig, internalConfig)
import Data.String (toLower)
import Effect.Aff (Aff, bracket)
import Effect.Class (class MonadEffect)
import Infra.Client.Postgres.Postgres as PostgreSql
import Util.Type.String.ToString (toString)
import Util.Type.Ulid (generateUlid)

generateTestDbNames :: ∀ m. MonadEffect m => m { store :: String, edge :: String }
generateTestDbNames = do
  ulid <- ʌ generateUlid
  let id = toLower (toString ulid)
  η { store: internalConfig.db.store.database <> "_test_" <> id, edge: internalConfig.db.edge.database <> "_test_" <> id }

viaRootDb :: DbSubConfig -> (PostgreSql.ConnectionPoolHandle -> Aff Ɩ) -> Aff Ɩ
viaRootDb config =
  bracket
    (PostgreSql.createConnectionPoolHandle (config { host = config.directHost }))
    PostgreSql.closeHandle

createTestDbs :: ∀ r. { store :: DbSubConfig, edge :: DbSubConfig | r } -> { store :: String, edge :: String } -> Aff Ɩ
createTestDbs config dbNames = do
  when (dbNames.store /= config.store.database) do
    viaRootDb config.store \handle -> do
      ø $ PostgreSql.query_ handle ("SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '" <> config.store.database <> "' AND pid <> pg_backend_pid()") []
      ø $ PostgreSql.query_ handle ("CREATE DATABASE " <> PostgreSql.escapeIdentifier dbNames.store) []

  when (dbNames.edge /= config.edge.database) do
    viaRootDb config.edge \handle -> do
      ø $ PostgreSql.query_ handle ("SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '" <> config.edge.database <> "' AND pid <> pg_backend_pid()") []
      ø $ PostgreSql.query_ handle ("CREATE DATABASE " <> PostgreSql.escapeIdentifier dbNames.edge) []

dropTestDbs :: ∀ r. { store :: DbSubConfig, edge :: DbSubConfig | r } -> { store :: String, edge :: String } -> Aff Ɩ
dropTestDbs config dbNames = do
  when (dbNames.store /= config.store.database) do
    viaRootDb config.store \handle -> do
      ø $ PostgreSql.query_ handle ("DROP DATABASE IF EXISTS " <> PostgreSql.escapeIdentifier dbNames.store <> " WITH (FORCE)") []

  when (dbNames.edge /= config.edge.database) do
    viaRootDb config.edge \handle -> do
      ø $ PostgreSql.query_ handle ("DROP DATABASE IF EXISTS " <> PostgreSql.escapeIdentifier dbNames.edge <> " WITH (FORCE)") []
