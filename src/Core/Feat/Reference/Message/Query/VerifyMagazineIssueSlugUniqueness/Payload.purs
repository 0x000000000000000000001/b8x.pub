module Core.Feat.Reference.Message.Query.VerifyMagazineIssueSlugUniqueness.Payload where

import Core.Mod.MagazineIssue.Slug.Message.Field.Slug (Slug, SlugField)

type Payload =
  { slug :: Slug
  }

type Fields =
  ( slug :: SlugField
  )
