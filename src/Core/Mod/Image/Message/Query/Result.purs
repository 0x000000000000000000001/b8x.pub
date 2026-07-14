module Core.Mod.Image.Message.Query.Result where

import Core.Message.Query.Result (Return)
import Core.Mod.Html.Html (NonEmptyHtml)
import Data.Maybe (Maybe)

type Illustration =
  { image :: Return Image
  , caption :: Return (Maybe NonEmptyHtml)
  , isFallback :: Return Boolean
  }

type Image =
  { src :: Return String
  , dimensions :: Return Dimensions
  }

type Dimensions =
  { width :: Return Int
  , height :: Return Int
  }
