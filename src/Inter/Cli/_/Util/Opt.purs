module Inter.Cli.Util.Opt where

import Proem

import Effect.Class (class MonadEffect)
import Options.Applicative (Parser, header, helper, info, (<**>))
import Options.Applicative as OptionsAp

execParser :: ∀ m a. MonadEffect m => String -> Parser a -> m a
execParser description optionsParser =
  ʌ $ OptionsAp.execParser $
    info
      (optionsParser <**> helper)
      (header description)