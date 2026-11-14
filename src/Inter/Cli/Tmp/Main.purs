module Inter.Cli.Tmp.Main (main) where

import Proem
import Effect (Effect)
import Effect.Class.Console (log)
import Effect.Aff (bracket)
import Inter.Cli.Util.Aff (runCliAff)
import Infra.Client.Postgres.Postgres as Postgres
import Config.InternalConfig (internalConfig)
import Run (AFF, EFFECT, runBaseAff')
import Type.Row (type (+))

type TMP = Postgres.READER_POSTGRES_EDGE_CLIENT + AFF + EFFECT + ()

main :: Effect Ɩ
main = runCliAff $ bracket (Postgres.createClient internalConfig.db.edge) Postgres.closeClient \client ->
  runBaseAff' $ Postgres.runPostgresEdgeClientReader client do
    log "--- END ---"
