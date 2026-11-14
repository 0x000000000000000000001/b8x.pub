module Inter.Cli.Util.Opt where

import Proem

import Effect.Class (class MonadEffect)
import Options.Applicative (Parser, header, helper, info, (<**>), customExecParser, prefs, columns)

execParser :: ∀ m a. MonadEffect m => String -> Parser a -> m a
execParser description optionsParser =
  ʌ $ customExecParser (prefs (columns 120)) $
    info
      (optionsParser <**> helper)
      (header description)