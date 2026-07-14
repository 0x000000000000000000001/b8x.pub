module Core.Feat.Reference.Message.Query.SearchBooks.Infra.Projection.CopyOnWrite where

import Proem

import Infra.Projection.CopyOnWrite (CopyOnWrite, ProjectionPersist)
import Run.State (State)

searchBooksProjectionWriteCopyState' = π :: Π "searchBooksProjectionWriteCopyState"

type SEARCH_BOOKS_PROJECTION_WRITE_COPY_STATE fx = (searchBooksProjectionWriteCopyState :: State CopyOnWrite | fx)

type SEARCH_BOOKS_PROJECTION_WRITE_COPY_PERSIST fx = (searchBooksProjectionWriteCopyPersist :: ProjectionPersist | fx)
