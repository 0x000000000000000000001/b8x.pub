module Core.Feat.Newsletter.Message.Query.SearchNewsletters.Projection.Index where

import Core.Feat.Newsletter.Message.Query.SearchNewsletters.Projection.Projection (SearchNewslettersProjection)

type SearchNewslettersProjectionRow r =
  ( searchNewsletters :: SearchNewslettersProjection
  | r
  )
