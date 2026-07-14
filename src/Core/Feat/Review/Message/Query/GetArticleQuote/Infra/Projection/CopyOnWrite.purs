module Core.Feat.Review.Message.Query.GetArticleQuote.Infra.Projection.CopyOnWrite where

import Proem

import Infra.Projection.CopyOnWrite (CopyOnWrite, ProjectionPersist)
import Run.State (State)

getArticleQuoteProjectionWriteCopyState' = π :: Π "getArticleQuoteProjectionWriteCopyState"

type GET_ARTICLE_QUOTE_PROJECTION_WRITE_COPY_STATE fx = (getArticleQuoteProjectionWriteCopyState :: State CopyOnWrite | fx)

type GET_ARTICLE_QUOTE_PROJECTION_WRITE_COPY_PERSIST fx = (getArticleQuoteProjectionWriteCopyPersist :: ProjectionPersist | fx)
