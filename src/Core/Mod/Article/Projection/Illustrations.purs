module Core.Mod.Article.Projection.Illustrations where

import Foreign as Foreign
import Proem
import Foreign.Index as Foreign.Index

import Core.Mod.Article.Illustrations.Illustrations as Base
import Core.Mod.Image.Image (Image(..))
import Yoga.JSON (class ReadForeign, class WriteForeign, readImpl)
import Foreign (Foreign)
import Data.Traversable (traverse)
import Data.Array as Array
import Data.Generic.Rep (class Generic)
import Data.Newtype (class Newtype)
import Util.Type.Random (class Random)
import Data.Nullable (Nullable, toMaybe)
import Core.Mod.Html.Html (NonEmptyHtml)

newtype Illustrations = Illustrations
  { illustrations :: Base.Illustrations
  , hasAtLeastOneLandscape :: Boolean
  , hasAtLeastOne :: Boolean
  }

derive instance Newtype Illustrations _
derive instance Generic Illustrations _
derive instance Eq Illustrations
derive instance Ord Illustrations
derive newtype instance Random Illustrations
derive newtype instance Show Illustrations
derive newtype instance WriteForeign Illustrations

instance ReadForeign Illustrations where
  readImpl json = do
    obj <- readImpl json
    illustrationsJson <- (Foreign.Index.readProp "illustrations" obj >>= readImpl)
    illustrations_ <- traverse decodeIllustrationJson illustrationsJson
    hasAtLeastOneLandscape_ <- (Foreign.Index.readProp "hasAtLeastOneLandscape" obj >>= readImpl)
    hasAtLeastOne_ <- (Foreign.Index.readProp "hasAtLeastOne" obj >>= readImpl)
    η $ Illustrations { illustrations: illustrations_, hasAtLeastOneLandscape: hasAtLeastOneLandscape_, hasAtLeastOne: hasAtLeastOne_ }

decodeIllustrationJson :: Foreign -> Foreign.F Base.Illustration
decodeIllustrationJson json = do
  obj <- readImpl json
  image <- (Foreign.Index.readProp "image" obj >>= readImpl)
  caption <- (Foreign.Index.readProp "caption" obj >>= readImpl)
  η { image, caption }


make :: Base.Illustrations -> Illustrations
make illustrations = Illustrations
  { illustrations
  , hasAtLeastOneLandscape: hasAtLeastOneLandscape illustrations
  , hasAtLeastOne: Array.length illustrations > 0
  }

hasAtLeastOneLandscape :: Base.Illustrations -> Boolean
hasAtLeastOneLandscape illustrations =
  illustrations #
    Array.any \{ image: Image img } -> img.dimensions.width > img.dimensions.height


