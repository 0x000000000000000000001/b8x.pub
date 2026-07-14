module Core.Mod.MimeType where

import Proem

import Data.Generic.Rep (class Generic)
import Data.Maybe (Maybe(..))
import Data.Show.Generic (genericShow)
import Util.Json.String (readStringImpl, writeStringImpl)
import Util.Type.Random (class Random, random)
import Util.Type.String.ToString (class FromString, class ToString)
import Yoga.JSON (class ReadForeign, class WriteForeign)

data MimeType = ImageJpeg | ImagePng | ImageWebp | ImageGif
data Extension = Jpeg | Jpg | Png | Webp | Gif

derive instance Eq MimeType
derive instance Ord MimeType
derive instance Generic MimeType _

derive instance Eq Extension
derive instance Ord Extension
derive instance Generic Extension _

mimeTypeToExtension :: MimeType -> Maybe (Array Extension)
mimeTypeToExtension = case _ of
  ImageJpeg -> Just [ Jpg, Jpeg ]
  ImagePng -> Just [ Png ]
  ImageWebp -> Just [ Webp ]
  ImageGif -> Just [ Gif ]

extensionToMimeType :: Extension -> Maybe MimeType
extensionToMimeType = case _ of
  Jpg -> Just ImageJpeg
  Jpeg -> Just ImageJpeg
  Png -> Just ImagePng
  Webp -> Just ImageWebp
  Gif -> Just ImageGif

instance Show MimeType where
  show = genericShow

instance ToString MimeType where
  toString ImageJpeg = "image/jpeg"
  toString ImagePng = "image/png"
  toString ImageWebp = "image/webp"
  toString ImageGif = "image/gif"

instance ToString Extension where
  toString Jpg = "jpg"
  toString Jpeg = "jpeg"
  toString Png = "png"
  toString Webp = "webp"
  toString Gif = "gif"

instance FromString MimeType where
  fromString = case _ of
    "image/jpeg" -> Just ImageJpeg
    "image/png" -> Just ImagePng
    "image/webp" -> Just ImageWebp
    "image/gif" -> Just ImageGif
    _ -> Nothing

instance WriteForeign MimeType where
  writeImpl = writeStringImpl

instance ReadForeign MimeType where
  readImpl = readStringImpl

instance Random MimeType where
  random = do
    isPng <- random
    η $ isPng == true ? ImagePng ↔ ImageJpeg

