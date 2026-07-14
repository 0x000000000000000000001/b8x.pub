module Core.Feat.Sitemap.Message.Query.ListYearArticles.Payload where

import Core.Feat.Sitemap.Message.Query.ListYearArticles.Field.Year (Year, YearField)

type Fields =
  ( year :: YearField
  )

type Payload =
  { year :: Year
  }
