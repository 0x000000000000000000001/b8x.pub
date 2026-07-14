module Core.Mod.Book.Cover.Message.Query.Opt where

import Proem

import Data.Maybe (Maybe(..))
import Core.Message.Query.Payload (Need(..))
import Core.Mod.Image.Message.Query.Opt (ImageInnerNeedsRow)

type CoverOptRow r =
  ( onlyIfWidthGreaterThan :: Maybe Int
  | r
  )

type CoverOpt = { | CoverOptRow () }

type CoverInnerNeeds = { | ImageInnerNeedsRow () }

defaultCoverOpt :: CoverOpt
defaultCoverOpt =
  { onlyIfWidthGreaterThan: Just 130
  }

defaultCoverInnerNeeds :: CoverInnerNeeds
defaultCoverInnerNeeds =
  { src: Needed { absolute: false } ι
  , dimensions: Needed ι { width: Needed ι ι, height: Needed ι ι }
  }
