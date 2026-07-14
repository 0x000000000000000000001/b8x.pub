module Core.Event.MagazineCustomSectionAdded.Payload where

import Core.Mod.MagazineIssue.CustomSection.Id.Id (CustomSectionId)
import Core.Mod.MagazineIssue.CustomSection.Name.Name (Name)
import Core.Mod.MagazineIssue.Id.Id (MagazineIssueId)

type Payload =
  { id :: CustomSectionId
  , magazineIssue :: MagazineIssueId
  , name :: Name
  }
