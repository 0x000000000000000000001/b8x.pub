module Core.Feat.Reference.Message.Command.ReferenceMagazineIssue.Projection.Index where

import Core.Feat.Reference.Message.Command.ReferenceMagazineIssue.Projection.Projection (ReferenceMagazineIssueProjection)

type ReferenceMagazineIssueProjectionRow r =
  ( referenceMagazineIssue :: ReferenceMagazineIssueProjection
  | r
  )
