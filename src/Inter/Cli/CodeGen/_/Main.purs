module Inter.Cli.CodeGen.Main where

import Proem
import Inter.Cli.CodeGen.Config as ConfigCommand
import Inter.Cli.CodeGen.Lexicon as LexiconCommand
import Inter.Cli.Util.Opt (execParser)
import Effect (Effect)
import Options.Applicative (Parser, command, header, hsubparser, info)
import Inter.Cli.CodeGen.CodeGenM (runCodeGenM)

data CodeGenCommand
  = Config ConfigCommand.Options
  | Lexicon LexiconCommand.Options

description :: String
description = "Code generation utilities"

parser :: Parser CodeGenCommand
parser =
  hsubparser
    (command
        ConfigCommand.shortModuleName
        (info
            (Config <$> ConfigCommand.parser)
            (header ConfigCommand.description)
        )
        <> command
          LexiconCommand.shortModuleName
          (info
              (Lexicon <$> LexiconCommand.parser)
              (header LexiconCommand.description)
          )
    )

main :: Effect Ɩ
main = do
  cmd <- execParser description parser
  runCodeGenM case cmd of
    Config opts -> ConfigCommand.run opts
    Lexicon opts -> LexiconCommand.run opts
