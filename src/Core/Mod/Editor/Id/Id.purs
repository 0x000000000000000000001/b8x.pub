module Core.Mod.Editor.Id.Id
  (EditorId
  , module Core.Mod.Id.Id
  ) where

import Core.Mod.Id.Id (make)
import Core.Mod.Id.Id as Id
import Core.Mod.Editor.Editor (Editor)

type EditorId = Id.Id Editor
