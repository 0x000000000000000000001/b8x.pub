module Core.Mod.Image.Image
  ( Image(..)
  ) where

import Yoga.JSON as JSON
import Proem
import Foreign.Index as Foreign.Index

import Core.Mod.MimeType (MimeType)
import Core.Mod.MimeType as MimeType
import Yoga.JSON (class ReadForeign, class WriteForeign, readImpl)
import Data.Generic.Rep (class Generic)
import Data.Newtype (class Newtype)
import Effect.Random (randomInt)
import Util.Type.Random (class Random, random)
import Util.Type.String.ToString (toString)
import Util.Type.Ulid (generateUlid)

newtype Image = Image
  { src :: String
  , hash :: String
  , mimeType :: MimeType
  , size :: Int
  , dimensions ::
      { width :: Int
      , height :: Int
      }
  }

instance Random Image where
  random = do
    id <- ʌ generateUlid

    mimeType <- random
    size <- ʌ $ randomInt 1000 1000_1000

    bool <- random @Boolean

    width <- ʌ $ randomInt 100 2000
    height <- ʌ $ randomInt 100 2000

    η $ Image
      { src:
          "path/to/"
            <> toString id
            <>
              ( case mimeType of
                  MimeType.ImagePng -> ".png"
                  MimeType.ImageJpeg -> bool ? ".jpg" ↔ ".jpeg"
                  MimeType.ImageWebp -> ".webp"
                  MimeType.ImageGif -> ".gif"
              )
      , hash: toString id
      , mimeType
      , size
      , dimensions: { width, height }
      }

derive instance Newtype Image _
derive instance Generic Image _
derive newtype instance Eq Image
derive newtype instance Ord Image
derive newtype instance Show Image
derive newtype instance WriteForeign Image

instance ReadForeign Image where
  readImpl json = do
    obj <- readImpl json
    src <- Foreign.Index.readProp "src" obj >>= JSON.readImpl
    hash <- Foreign.Index.readProp "hash" obj >>= JSON.readImpl
    mimeType <- Foreign.Index.readProp "mimeType" obj >>= JSON.readImpl
    size <- Foreign.Index.readProp "size" obj >>= JSON.readImpl
    dimensionsJson <- Foreign.Index.readProp "dimensions" obj >>= JSON.readImpl
    dimensionsObj <- readImpl dimensionsJson
    width <- Foreign.Index.readProp "width" dimensionsObj >>= JSON.readImpl
    height <- Foreign.Index.readProp "height" dimensionsObj >>= JSON.readImpl
    pure $ Image { src, hash, mimeType, size, dimensions: { width, height } }



