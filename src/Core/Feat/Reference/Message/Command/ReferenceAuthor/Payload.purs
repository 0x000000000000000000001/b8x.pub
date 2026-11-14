module Core.Feat.Reference.Message.Command.ReferenceAuthor.Payload where

import Core.Feat.Reference.Message.Command.ReferenceAuthor.Field.PortraitUrl (Portrait, PortraitField)
import Core.Mod.Author.Biography.Message.Field (Biography, BiographyField)
import Core.Mod.Author.Id.Message.Field.AutoId (Id, IdField)
import Core.Mod.Author.Name.Message.Field (Name, NameField)

type Payload =
  { id :: Id
  , name :: Name
  , biography :: Biography
  , portrait :: Portrait
  -- , legacyIds :: LegacyIds
  }

type Fields =
  ( id :: IdField
  , name :: NameField
  , biography :: BiographyField
  , portrait :: PortraitField
  -- , legacyIds :: LegacyIdsField
  )

