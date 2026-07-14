module Core.Feat.Reference.Message.Query.VerifyMagazineIssueSlugUniqueness.Exception.Index where

import Core.Feat.Reference.Message.Query.VerifyMagazineIssueSlugUniqueness.Exception.MagazineIssueSlugAlreadyTaken (MagazineIssueSlugAlreadyTakenRow)
import Type.Row (type (+))

type VerifyMagazineIssueSlugUniquenessExceptionRow r =
  MagazineIssueSlugAlreadyTakenRow
    + r
