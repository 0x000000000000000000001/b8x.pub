module Core.Mod.MagazineIssue.CustomSection.Id.Id
  ( CustomSectionId
  , module Core.Mod.Id.Id
  ) where

import Core.Mod.Id.Id (make)
import Core.Mod.Id.Id as Id
import Core.Mod.MagazineIssue.CustomSection.CustomSection (CustomSection)

type CustomSectionId = Id.Id CustomSection
