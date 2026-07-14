module Inter.Ui.Mod.Separator.Type
  (Input
  , TextElementTag(..)
  ) where

import Proem

import Data.Generic.Rep (class Generic)
import Data.Show.Generic (genericShow)

data TextElementTag = H1 | H2 | H3 | Div

derive instance Generic TextElementTag _
instance Show TextElementTag where
  show = genericShow

type Input =
  { text :: String
  , textElementTag :: TextElementTag
  , loading :: Boolean
  }
