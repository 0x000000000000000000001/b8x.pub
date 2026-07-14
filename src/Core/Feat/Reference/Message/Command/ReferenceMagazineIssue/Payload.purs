module Core.Feat.Reference.Message.Command.ReferenceMagazineIssue.Payload where

import Core.Mod.MagazineIssue.Id.Message.Field.AutoId (Id, IdField)
import Core.Mod.MagazineIssue.LegacyId.Message.Field (LegacyId, LegacyIdField)
import Core.Mod.MagazineIssue.Name.Message.Field (Name, NameField)
import Core.Mod.MagazineIssue.Special.Message.Field (Special, SpecialField)
import Core.Mod.MagazineIssue.Complement.Message.Field (Complement, ComplementField)
import Core.Mod.MagazineIssue.Number.Message.Field (IssueNumber, IssueNumberField)
import Core.Feat.Reference.Message.Command.ReferenceMagazineIssue.Field.CoverUrl (Cover, CoverField)
import Core.Mod.MagazineIssue.ReleasedAt.Message.Field (ReleasedAt, ReleasedAtField)

import Core.Feat.Reference.Message.Command.ReferenceMagazineIssue.Field.Slug (Slug, SlugField)

type Payload =
  { id :: Id
  , name :: Name
  , legacyId :: LegacyId
  , special :: Special
  , complement :: Complement
  , number :: IssueNumber
  , cover :: Cover
  , releasedAt :: ReleasedAt
  , slug :: Slug
  }

type Fields =
  (id :: IdField
  , name :: NameField
  , legacyId :: LegacyIdField
  , special :: SpecialField
  , complement :: ComplementField
  , number :: IssueNumberField
  , cover :: CoverField
  , releasedAt :: ReleasedAtField
  , slug :: SlugField
  )
