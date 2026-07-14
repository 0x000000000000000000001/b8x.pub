module Core.Event.MagazineIssueReferenced.Payload where

import Core.Mod.Image.Image (Image)
import Core.Mod.MagazineIssue.Id.Id (MagazineIssueId)
import Core.Mod.MagazineIssue.LegacyId.LegacyId (LegacyId)
import Core.Mod.MagazineIssue.Name.Name (Name)
import Core.Mod.MagazineIssue.Number.Number (IssueNumber)
import Core.Mod.MagazineIssue.ReleasedAt.ReleasedAt (ReleasedAt)
import Core.Mod.MagazineIssue.Slug.Slug (Slug)
import Data.Maybe (Maybe)

type Payload =
  { id :: MagazineIssueId
  , name :: Name
  , legacyId :: LegacyId
  , special :: Boolean
  , complement :: Boolean
  , number :: IssueNumber
  , cover :: Maybe Image
  , releasedAt :: Maybe ReleasedAt
  , slug :: Slug
  }
