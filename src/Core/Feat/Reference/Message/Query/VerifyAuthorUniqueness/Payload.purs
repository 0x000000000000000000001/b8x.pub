module Core.Feat.Reference.Message.Query.VerifyAuthorUniqueness.Payload where

import Core.Mod.Author.Name.Message.Field (NameField)
import Core.Mod.Author.Name.Name (Name)
import Core.Mod.Author.LegacyIds.LegacyIds (LegacyIds)
import Core.Mod.Author.LegacyIds.Message.Field (LegacyIdsField)

type Payload =
  { name :: Name
  , legacyIds :: LegacyIds
  }

type Fields =
  ( name :: NameField
  , legacyIds :: LegacyIdsField
  )
