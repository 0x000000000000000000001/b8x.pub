module Core.Feat.Reference.Message.Query.SearchEditors.Projection.Index where

import Core.Feat.Reference.Message.Query.SearchEditors.Projection.Projection (SearchEditorsProjection)

type SearchEditorsProjectionRow r =
  ( searchEditors ∷ SearchEditorsProjection
  | r
  )
