module Inter.Cli.Ping.Main (main) where

import Proem

import Effect (Effect)
import Effect.Class.Console (log)
import Inter.Cli.Ping.PingM (runPingM)
import Inter.Cli.Util.Aff (runCliAff)

main :: Effect Ɩ
main = runCliAff $ runPingM $ log "pong"
