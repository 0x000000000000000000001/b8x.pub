module Core.Mod.MagazineIssue.Id.Id
  (MagazineIssue
  , MagazineIssueId
  , module Core.Mod.Id.Id
  ) where

import Core.Mod.Id.Id (make)
import Core.Mod.Id.Id as Id

data MagazineIssue

type MagazineIssueId = Id.Id MagazineIssue
