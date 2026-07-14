module Core.Event.MagazineIssueDereferenced.Payload where

import Core.Mod.MagazineIssue.Id.Id (MagazineIssueId)

type Payload =
  { issue :: MagazineIssueId
  }
