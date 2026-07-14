module Core.Feat.Review.Message.Command.AddMagazineCustomSection.Payload where

import Core.Mod.MagazineIssue.CustomSection.Id.Message.Field.AutoId (CustomSectionId, CustomSectionIdField)
import Core.Mod.MagazineIssue.CustomSection.Name.Message.Field (Name, NameField)
import Core.Mod.MagazineIssue.Id.Message.Field.MagazineIssue (MagazineIssue, MagazineIssueField)

type Payload =
  { id :: CustomSectionId
  , name :: Name
  , magazineIssue :: MagazineIssue
  }

type Fields =
  ( id :: CustomSectionIdField
  , name :: NameField
  , magazineIssue :: MagazineIssueField
  )
