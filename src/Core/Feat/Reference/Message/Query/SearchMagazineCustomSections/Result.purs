module Core.Feat.Reference.Message.Query.SearchMagazineCustomSections.Result where

import Core.Mod.MagazineIssue.CustomSection.Id.Id (CustomSectionId)
import Core.Mod.MagazineIssue.CustomSection.Name.Name as CustomSectionName
import Core.Mod.MagazineIssue.Id.Id (MagazineIssueId)
import Core.Message.Query.Result (Return)

type Result =
  { customSections ::
      Array
        { id :: Return CustomSectionId
        , magazineIssue :: Return MagazineIssueId
        , name :: Return CustomSectionName.Name
        }
  , limit :: Int
  , hasNextPage :: Boolean
  }
