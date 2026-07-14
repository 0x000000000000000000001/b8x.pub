module Core.Feat.Reference.Message.Query.GetAuthor.Projection.Index where

import Core.Feat.Reference.Message.Query.GetAuthor.Projection.Projection (GetAuthorProjection)

type Row r = ( getAuthor ∷ GetAuthorProjection | r )
