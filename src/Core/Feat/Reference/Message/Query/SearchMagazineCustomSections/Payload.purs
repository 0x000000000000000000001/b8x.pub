module Core.Feat.Reference.Message.Query.SearchMagazineCustomSections.Payload where

import Core.Feat.Reference.Message.Query.SearchMagazineCustomSections.Projection.Message.Field.Filter (Filter, FilterField)
import Core.Mod.MagazineIssue.CustomSection.Id.Message.Field.AfterCustomSection (AfterCustomSection, AfterCustomSectionField)
import Core.Mod.Projection.Finder.BoundedLimit.BoundedLimit (BoundedLimit)
import Core.Mod.Projection.Finder.BoundedLimit.Message.Field (BoundedLimitField)
import Core.Feat.Reference.Message.Query.SearchMagazineCustomSections.Field.Needs (Needs, NeedsField)
import Core.Mod.Projection.Finder.Expectation.Message.Field (Expectation, ExpectationField)

type Payload =
  { filter :: Filter
  , limit :: BoundedLimit
  , after :: AfterCustomSection
  , needs :: Needs
  , expectation :: Expectation
  }

type Fields =
  ( filter :: FilterField
  , limit :: BoundedLimitField
  , after :: AfterCustomSectionField
  , needs :: NeedsField
  , expectation :: ExpectationField
  )
