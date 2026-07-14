module Inter.Cli.Worker.Registry where

import Data.Nullable as Data.Nullable
import Proem

import Core.Message.Command.Command (class IsCommand)
import Core.Message.Command.Handle.Handle as CommandHandle
import Core.Message.Command.Index (CommandRow)
import Core.Feat.Process.Index (ProcessRow)
import Core.Feat.Process.Process (class IsProcess)
import Core.Feat.Process.Process as Process
import Inter.Cli.Worker.WorkerM (WorkerM)
import Foreign (Foreign)
import Foreign as Foreign
import Yoga.JSON (class ReadForeign, class WriteForeign, readImpl, writeImpl)
import Control.Monad.Except (runExcept)
import Data.Either (Either(..))
import Data.Symbol (class IsSymbol)
import Effect.Exception (throw)
import Foreign.Object (Object)
import Foreign.Object as Object
import Prim.RowList (Cons)
import Util.Type.Type (class Reflect, reflectName)
import Util.Type.Row.Registry (class RegistryBuilder, buildRegistry, buildRegistryFromRowList)

type CommandHandler = Foreign -> WorkerM Foreign


class ToWorkerOutput a where
  toWorkerOutput :: a -> Foreign

instance ToWorkerOutput Unit where
  toWorkerOutput _ = Foreign.unsafeToForeign (Data.Nullable.null :: Data.Nullable.Nullable Unit)
else instance WriteForeign a => ToWorkerOutput a where
  toWorkerOutput = writeImpl

commandHandlerRegistry :: Object CommandHandler
commandHandlerRegistry = buildRegistry @WorkerCommandHandlers @CommandRow

type Process = Foreign -> WorkerM Ɩ

processRegistry :: Object Process
processRegistry = buildRegistry @WorkerProcesses @ProcessRow

data WorkerCommandHandlers

instance
  (IsSymbol cmdName
  , IsCommand cmd state fields payload a
  , Reflect cmd
  , ToWorkerOutput a
  , RegistryBuilder WorkerCommandHandlers tail CommandHandler
  ) =>
  RegistryBuilder WorkerCommandHandlers (Cons cmdName cmd tail) CommandHandler where
  buildRegistryFromRowList =
    let
      tailRegistry = buildRegistryFromRowList @WorkerCommandHandlers @tail
      cmdName = reflectName @cmd
      handler = handleCommand @cmd
    in
      Object.insert cmdName handler tailRegistry

data WorkerProcesses

instance
  (IsSymbol processName
  , IsProcess process event payload
  , Reflect process
  , ReadForeign payload
  , RegistryBuilder WorkerProcesses tail Process
  ) =>
  RegistryBuilder WorkerProcesses (Cons processName process tail) Process where
  buildRegistryFromRowList =
    let
      tailRegistry = buildRegistryFromRowList @WorkerProcesses @tail
      processName = reflectName @process
      handler = handleEvent @process
    in
      Object.insert processName handler tailRegistry

handleCommand
  :: ∀ @cmd state fields payload a
   . IsCommand cmd state fields payload a
  => Reflect cmd
  => ToWorkerOutput a
  => CommandHandler
handleCommand json = do
  case runExcept (readImpl @cmd json) of
    Left err -> ʌ $ throw $ "Invalid command: " <> show err
    Right cmd -> do
      res <- CommandHandle.handleCommand true cmd
      η $ toWorkerOutput res

handleEvent
  :: ∀ @process event payload
   . IsProcess process event payload
  => Process
handleEvent json = do
  case runExcept (readImpl @payload json) of
    Left err -> ʌ $ throw $ "Invalid event: " <> show err
    Right payload -> Process.handleEvent @process payload
