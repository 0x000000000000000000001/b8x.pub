module Core.Mod.Article.Illustrations.Illustrations where

import Proem

import Core.Mod.Html.Html (NonEmptyHtml)
import Core.Mod.Image.Image (Image)
import Data.Maybe (Maybe)

type Illustration' image =
  { image :: image
  , caption :: Maybe NonEmptyHtml
  }

type Illustration = Illustration' Image

type Illustrations = Array Illustration

image_ = ᴠ'' @"image" @(Illustration' Ɩ) :: String
caption_ = ᴠ'' @"caption" @(Illustration' Ɩ) :: String
