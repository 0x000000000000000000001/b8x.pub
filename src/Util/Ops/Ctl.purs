module Util.Ops.Ctl where

import Proem

import Effect.Class (class MonadEffect)
import Effect.Exception (catchException, message)
import Node.Encoding (Encoding(..))
import Node.FS.Sync (appendTextFile)
import Util.File.Path (_rootDirAbsolutePath)
import Util.Log.Error (error)
import Util.Log.Info (info)
import Util.Type.String.String (caseToKebab)

updateService :: ∀ m. MonadEffect m => String -> m Ɩ
updateService serviceName = do
  let 
    name = caseToKebab serviceName
    file = _rootDirAbsolutePath <> "var/sock/update_" <> name

  info $ "Requesting zero-downtime update to the orchestrator, for service: " <> name
  
  ʌ $ catchException
    (\e -> error $ "Failed to request update for " <> name <> ": " <> message e)
    (appendTextFile UTF8 file "") -- Created if it does not exist.
