module Core.Feat.Reference.Message.Command.ReferenceAuthor.Payload where

import Core.Mod.Author.Biography.Biography (Biography)
import Core.Mod.Author.Biography.Message.Field (BiographyField)
import Core.Mod.Author.Id.Message.Field.AutoId (Id, IdField)
import Core.Mod.Author.LegacyIds.Message.Field (LegacyIdsField)
import Core.Mod.Author.LegacyIds.LegacyIds (LegacyIds)
import Core.Mod.Author.Name.Message.Field (Name, NameField)
import Core.Feat.Reference.Message.Command.ReferenceAuthor.Field.PortraitUrl (Portrait, PortraitField)

type Payload =
  { id :: Id
  , name :: Name
  , biography :: Biography
  , legacyIds :: LegacyIds
  , portrait :: Portrait
  }

type Fields =
  (id :: IdField
  , name :: NameField
  , biography :: BiographyField
  , legacyIds :: LegacyIdsField
  , portrait :: PortraitField
  )
