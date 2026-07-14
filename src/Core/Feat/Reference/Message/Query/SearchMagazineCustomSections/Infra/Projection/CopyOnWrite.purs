module Core.Feat.Reference.Message.Query.SearchMagazineCustomSections.Infra.Projection.CopyOnWrite where

import Proem

import Infra.Projection.CopyOnWrite (CopyOnWrite, ProjectionPersist)
import Run.State (State)

searchMagazineCustomSectionsProjectionWriteCopyState' = π :: Π "searchMagazineCustomSectionsProjectionWriteCopyState"

type SEARCH_MAGAZINE_CUSTOM_SECTIONS_PROJECTION_WRITE_COPY_STATE fx = (searchMagazineCustomSectionsProjectionWriteCopyState :: State CopyOnWrite | fx)

type SEARCH_MAGAZINE_CUSTOM_SECTIONS_PROJECTION_WRITE_COPY_PERSIST fx = (searchMagazineCustomSectionsProjectionWriteCopyPersist :: ProjectionPersist | fx)
