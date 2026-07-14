module Inter.Cli.Logic.Util where

import Proem

import Inter.Cli.Util.Input as Input
import Data.Maybe (Maybe(..))
import Run (AFF, EFFECT, Run)
import Type.Row (type (+))

-- | Get field value from options or ask interactively
askField :: ∀ fx. Maybe String -> String -> Run (AFF + EFFECT + fx) String
askField maybeValue prompt = case maybeValue of
  Just val -> η val
  Nothing -> Input.ask prompt
