module Core.Mod.Trace.Cause
  ( CauseNode(..)
  ) where

import Proem

import Yoga.JSON.Generics (genericWriteForeignTaggedSum, genericReadForeignTaggedSum)
import Yoga.JSON.Generics.TaggedSumRep (defaultOptions)
import Core.Event.Id (EventId)
import Core.Mod.Trace.Id (AppendId, RunId)
import Core.Mod.Trace.Subject (Subject)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Generic.Rep (class Generic)
import Data.Maybe (Maybe)

data CauseNode
  = Event { name :: String, id :: EventId, run :: RunId, append :: Maybe AppendId, cause :: Maybe CauseNode }
  | Command { name :: String, run :: RunId, subject :: Maybe Subject, cause :: Maybe CauseNode }
  | Query { name :: String, run :: RunId, subject :: Maybe Subject }

derive instance Generic CauseNode _
derive instance Eq CauseNode

instance WriteForeign CauseNode where
  writeImpl x = (genericWriteForeignTaggedSum defaultOptions) x

instance ReadForeign CauseNode where
  readImpl f = (genericReadForeignTaggedSum defaultOptions) f

