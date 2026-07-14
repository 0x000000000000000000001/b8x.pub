module Inter.Cli.Util.Exit
  (exit
  , exitError
  , exitSuccess
  ) where

import Proem

import Effect.Class (class MonadEffect)
import Node.Process (exit')

exit :: ∀ m a. MonadEffect m => Int -> m a
exit = ʌ ◁ exit'

exitSuccess :: ∀ m a. MonadEffect m => m a
exitSuccess = exit 0

exitError :: ∀ m a. MonadEffect m => m a
exitError = exit 1