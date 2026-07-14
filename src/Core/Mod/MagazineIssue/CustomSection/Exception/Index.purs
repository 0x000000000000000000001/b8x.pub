module Core.Mod.MagazineIssue.CustomSection.Exception.Index where

import Core.Mod.MagazineIssue.CustomSection.Exception.MagazineCustomSectionAlreadyAdded (MagazineCustomSectionAlreadyAddedRow)
import Core.Mod.MagazineIssue.CustomSection.Exception.MagazineCustomSectionCannotBeAdded (MagazineCustomSectionCannotBeAddedRow)
import Type.Row (type (+))

type CustomSectionExceptionRow r =
  MagazineCustomSectionAlreadyAddedRow
    + MagazineCustomSectionCannotBeAddedRow
    + r
