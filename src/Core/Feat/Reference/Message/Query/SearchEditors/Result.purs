module Core.Feat.Reference.Message.Query.SearchEditors.Result where

import Core.Mod.Editor.Id.Id (EditorId)
import Core.Mod.Editor.Name.Name (Name)
import Core.Message.Query.Result (Return)

type Result =
  { editors ::
      Array
        { id :: Return EditorId
        , name :: Return Name
        , legacyBookIds :: Return (Array Int)
        }
  , limit :: Int
  , hasNextPage :: Boolean
  }
