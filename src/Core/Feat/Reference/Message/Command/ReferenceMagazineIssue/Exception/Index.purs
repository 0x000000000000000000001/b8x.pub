module Core.Feat.Reference.Message.Command.ReferenceMagazineIssue.Exception.Index where

import Core.Mod.MagazineIssue.Exception.MagazineIssueAlreadyReferenced (MagazineIssueAlreadyReferenced)
import Core.Feat.Reference.Message.Command.ReferenceMagazineIssue.Exception.MagazineIssueCannotBeReferenced (MagazineIssueCannotBeReferenced)

type ReferenceMagazineIssueExceptionRow r =
  ("Core.Mod.MagazineIssue.Exception.MagazineIssueAlreadyReferenced" ∷ MagazineIssueAlreadyReferenced
  , "Core.Feat.Reference.Message.Command.ReferenceMagazineIssue.Exception.MagazineIssueCannotBeReferenced" ∷ MagazineIssueCannotBeReferenced
  | r
  )
