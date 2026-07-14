module Core.Event.EditorDereferenced.Payload where

import Core.Mod.Editor.Id.Id (EditorId)

type Payload =
  { editor :: EditorId
  }
