module Core.Feat.Review.Message.Query.GetFrontPage.Result.Result where

import Proem

import Core.Message.Query.Result (Return)
import Core.Feat.Review.Message.Query.GetFrontPage.Result.Article.Article (Article)
import Data.Lens (Lens')
import Data.Lens.Record (prop)

type Result =
  { topLeft :: Return Article
  , topRight :: Return Article
  , center :: Return Article
  , bottomLeft :: Return Article
  , bottomRight :: Return Article
  }

_topLeft :: Lens' Result (Return Article)
_topLeft = prop (π @"topLeft")

_topRight :: Lens' Result (Return Article)
_topRight = prop (π @"topRight")

_center :: Lens' Result (Return Article)
_center = prop (π @"center")

_bottomLeft :: Lens' Result (Return Article)
_bottomLeft = prop (π @"bottomLeft")

_bottomRight :: Lens' Result (Return Article)
_bottomRight = prop (π @"bottomRight")
