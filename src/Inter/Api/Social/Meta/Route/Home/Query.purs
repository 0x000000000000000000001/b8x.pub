module Inter.Api.Social.Meta.Route.Home.Query where

import Proem

import Effect.Aff (Aff)
import Inter.Api.Social.Meta.Type (Meta, defaultMeta)

import Data.Maybe (Maybe(..))

queryMeta :: Aff (Maybe Meta)
queryMeta = η (Just defaultMeta)
