module Core.Feat.Reference.Message.Query.SearchMagazineIssues.Result where

import Core.Mod.Image.Message.Query.Result as Result
import Core.Mod.MagazineIssue.Id.Id (MagazineIssueId)
import Core.Mod.MagazineIssue.Name.Name (Name)
import Core.Mod.MagazineIssue.Number.Number (IssueNumber)
import Core.Mod.MagazineIssue.Slug.Slug (Slug)
import Core.Message.Query.Result (Return)
import Data.Maybe (Maybe)
import Core.Mod.Time.Instant (Instant)

type Result =
  { magazineIssues ::
      Array
        { id :: Return MagazineIssueId
        , name :: Return Name
        , legacyId :: Return (Maybe Int)
        , special :: Return Boolean
        , complement :: Return Boolean
        , number :: Return IssueNumber
        , cover :: Return (Maybe Result.Image)
        , slug :: Return Slug
        , seoUpdatedAt :: Return Instant
        }
  , limit :: Int
  , hasNextPage :: Boolean
  }
