module Core.Feat.Reference.Message.Command.ReferenceEditor.Payload where

import Core.Mod.Book.LegacyIds.Message.Field (LegacyIds, LegacyIdsField)
import Core.Mod.Editor.Id.Message.Field.AutoId (Id, IdField)
import Core.Mod.Editor.Name.Message.Field (Name, NameField)

type Payload =
  { id :: Id
  , name :: Name
  , legacyBookIds :: LegacyIds
  }

type Fields =
  (id :: IdField
  , name :: NameField
  , legacyBookIds :: LegacyIdsField
  )
