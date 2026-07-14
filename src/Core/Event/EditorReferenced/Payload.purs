module Core.Event.EditorReferenced.Payload where

import Core.Mod.Editor.Id.Id (EditorId)
import Core.Mod.Editor.Name.Name (Name)

type Payload =
  { id :: EditorId
  , name :: Name
  , legacyBookIds :: Array Int
  }
