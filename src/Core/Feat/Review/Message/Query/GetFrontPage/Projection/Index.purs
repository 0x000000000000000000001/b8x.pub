module Core.Feat.Review.Message.Query.GetFrontPage.Projection.Index where

import Core.Feat.Review.Message.Query.GetFrontPage.Projection.Projection (GetFrontPageProjection)

type GetFrontPageProjectionRow r
  = ( getFrontPage :: GetFrontPageProjection
    | r
    )
