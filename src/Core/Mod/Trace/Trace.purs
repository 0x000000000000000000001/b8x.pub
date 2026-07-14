module Core.Mod.Trace.Trace
  ( READER_TRACE
  , Trace
  , askSubject
  , askTrace
  , readerTrace'
  , runTraceReader
  ) where

import Proem

import Core.Mod.Trace.Cause (CauseNode(..))
import Core.Mod.Trace.Id (AppendId, RunId)
import Core.Mod.Trace.Subject (Subject)
import Data.Maybe (Maybe(..))
import Run as RunM
import Run.Reader (Reader, askAt, runReaderAt)
import Type.Row (type (+))

-- | This is a call-context stack.
-- | It will grow when new tasks are spawned.
type Trace =
  { run :: RunId
  , append :: Maybe AppendId
  , cause :: Maybe CauseNode
  , overriddenAt :: Maybe String
  }

type READER_TRACE fx = (readerTrace :: Reader Trace | fx)

readerTrace' = π :: Π "readerTrace"

runTraceReader :: ∀ fx a. Trace -> RunM.Run (READER_TRACE + fx) a -> RunM.Run fx a
runTraceReader = runReaderAt readerTrace'

askTrace :: ∀ fx. RunM.Run (READER_TRACE + fx) Trace
askTrace = askAt readerTrace'

askSubject :: ∀ fx. RunM.Run (READER_TRACE + fx) (Maybe Subject)
askSubject = askTrace <#> \c -> case c.cause of
  Just (Command cmd) -> cmd.subject
  Just (Query query) -> query.subject
  _ -> Nothing
