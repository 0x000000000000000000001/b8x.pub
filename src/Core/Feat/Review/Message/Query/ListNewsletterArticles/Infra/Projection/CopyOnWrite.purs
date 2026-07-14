module Core.Feat.Review.Message.Query.ListNewsletterArticles.Infra.Projection.CopyOnWrite where

import Proem

import Infra.Projection.CopyOnWrite (CopyOnWrite, ProjectionPersist)
import Run.State (State)

listNewsletterArticlesProjectionWriteCopyState' = π :: Π "listNewsletterArticlesProjectionWriteCopyState"

type LIST_NEWSLETTER_ARTICLES_PROJECTION_WRITE_COPY_STATE fx = (listNewsletterArticlesProjectionWriteCopyState :: State CopyOnWrite | fx)

type LIST_NEWSLETTER_ARTICLES_PROJECTION_WRITE_COPY_PERSIST fx = (listNewsletterArticlesProjectionWriteCopyPersist :: ProjectionPersist | fx)
