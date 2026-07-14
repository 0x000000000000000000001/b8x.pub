module Core.Feat.Process.Process where

import Proem

import Core.Exception.Index (EXCEPT_LOGIC)
import Core.Message.Queue (QUEUE)
import Core.Feat.Effect.Generate (GENERATE)
import Run (Run)
import Type.Row (type (+))

import Yoga.JSON (class ReadForeign)
import Util.Type.Type (class Reflect)

import Core.Mod.Trace.Trace (READER_TRACE)

class (Reflect process, Reflect event, ReadForeign payload) <= IsProcess (process :: Type) (event :: Type) (payload :: Type) | process -> event, process -> payload where
  async :: Boolean

  handleEvent :: ∀ fx. payload -> Run (QUEUE + EXCEPT_LOGIC + READER_TRACE + GENERATE + fx) Ɩ
