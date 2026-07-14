module Inter.Cli.Ping.PingM where

import Effect.Aff (Aff)
import Run (Run, AFF, EFFECT, runBaseAff')
import Type.Row (type (+))

type PING =
  AFF
    + EFFECT
    + ()

type PingM = Run PING

runPingM :: ∀ a. PingM a -> Aff a
runPingM = runBaseAff'
