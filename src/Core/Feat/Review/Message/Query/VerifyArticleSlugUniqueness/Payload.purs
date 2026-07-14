module Core.Feat.Review.Message.Query.VerifyArticleSlugUniqueness.Payload where

import Core.Mod.Article.Slug.Message.Field.Slug (SlugField)
import Core.Mod.Article.Slug.Slug (Slug)

type Payload =
  { slug :: Slug
  }

type Fields =
  ( slug :: SlugField
  )
