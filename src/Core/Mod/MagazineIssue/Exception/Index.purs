module Core.Mod.MagazineIssue.Exception.Index where

import Core.Mod.MagazineIssue.Slug.Exception (SlugExceptionRow)
import Core.Mod.MagazineIssue.Identifier.Exception (IdentifierExceptionRow)
import Core.Mod.MagazineIssue.Exception.MagazineIssueDoesNotExist (MagazineIssueDoesNotExistRow)
import Core.Mod.MagazineIssue.CustomSection.Exception.Index (CustomSectionExceptionRow)
import Type.Row (type (+))

type MagazineIssueExceptionRow r =
  SlugExceptionRow
    + IdentifierExceptionRow
    + MagazineIssueDoesNotExistRow
    + CustomSectionExceptionRow
    + r
