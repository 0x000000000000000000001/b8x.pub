module Core.Feat.Reference.Message.Query.SearchMagazineCustomSections.Projection.Index where

import Core.Feat.Reference.Message.Query.SearchMagazineCustomSections.Projection.Projection (SearchMagazineCustomSectionsProjection)

type SearchMagazineCustomSectionsProjectionRow r =
  ( searchMagazineCustomSections :: SearchMagazineCustomSectionsProjection
  | r
  )


