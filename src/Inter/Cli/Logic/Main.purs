module Inter.Cli.Logic.Main where

import Proem

import Inter.Cli.Logic.LogicM (acquire, complete, runLogicM)
import Core.Mod.Id.Id as Id
import Inter.Cli.Logic.Registry (Actions, registry, RegistryEntry)
import Core.Mod.Trace.Cause (CauseNode(..))
import Core.Mod.Trace.Subject (Subject(..))
import Yoga.JSON (unsafeStringify)
import Data.Foldable (foldMap)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Data.Newtype (unwrap)
import Effect (Effect)
import Effect.Aff (bracket)
import Foreign.Object (Object)
import Foreign.Object as Object
import Options.Applicative (Parser, command, help, hsubparser, long, short, switch)
import Inter.Cli.Util.Aff (runCliAff)
import Util.Log.Error (error)
import Util.Log.Except (except)
import Util.Log.Log (log)
import Util.Log.Success (success)
import Inter.Cli.Util.Opt (execParser)
import Util.I18n (Language(..), translate)
import Util.Type.String.String (upperCaseFirst)
import Util.Type.Type (reflectVariantKeyName)

type Input =
  { async :: Boolean
  , command :: Actions
  }

parser :: Object RegistryEntry -> Parser Input
parser registry = ado
  async <- switch (long "async" <> short 'a' <> help "Dispatch command asynchronously")
  command' <- hsubparser (Object.foldMap (\k v -> command k v.info <> foldMap (\a -> command a.name a.info) v.aliases) registry)
  in { async, command: command' }

main :: Effect Ɩ
main = runCliAff do
  input <- ʌ $ execParser "Execute a command" $ parser registry

  if input.async then bracket acquire complete \ctx -> do
    case input.command.askQueue of
      Nothing -> error "Async not supported."
      Just askQueue -> do
        runId <- ʌ Id.generate
        let cause = { run: runId, append: Nothing, cause: Nothing, overriddenAt: Nothing }
        result <- runLogicM ctx cause askQueue

        case result of
          Left e -> except $ "[" <> (upperCaseFirst $ reflectVariantKeyName $ unwrap e) <> "] " <> (translate En e)
          Right _ -> success "Command dispatched asynchronously."
  else bracket acquire complete \ctx -> do
    runId <- ʌ Id.generate
    let
      causeNode =
        if input.command.isCommand then Command { run: runId, subject: Just CliAdmin, name: input.command.name, cause: Nothing }
        else Query { run: runId, subject: Just CliAdmin, name: input.command.name }
      cause = { run: runId, append: Nothing, cause: Just causeNode, overriddenAt: Nothing }
    result <- runLogicM ctx cause input.command.askHandle

    case result of
      Left e -> except $ "[" <> (upperCaseFirst $ reflectVariantKeyName $ unwrap e) <> "] " <> (translate En e)
      Right res -> do
        log ""
        success $ "Done. Result:"
        log $ if unsafeStringify res == "{}" || unsafeStringify res == "null" then "{}" else unsafeStringify res
