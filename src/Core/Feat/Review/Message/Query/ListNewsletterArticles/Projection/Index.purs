module Core.Feat.Review.Message.Query.ListNewsletterArticles.Projection.Index where

import Core.Feat.Review.Message.Query.ListNewsletterArticles.Projection.Projection (ListNewsletterArticlesProjection)

type ListNewsletterArticlesProjectionRow r
  = ( listNewsletterArticles :: ListNewsletterArticlesProjection
    | r
    )
