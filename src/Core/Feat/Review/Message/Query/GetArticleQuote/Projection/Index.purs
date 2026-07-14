module Core.Feat.Review.Message.Query.GetArticleQuote.Projection.Index where

import Core.Feat.Review.Message.Query.GetArticleQuote.Projection.Projection (GetArticleQuoteProjection)

type GetArticleQuoteProjectionRow r =
  ( getArticleQuote :: GetArticleQuoteProjection
  | r
  )
