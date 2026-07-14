module Core.Message.Command.Handle.Upload
  ( AutocropBlackWhite
  , AutocropTransparent
  , UPLOAD
  , Upload(..)
  , interpretUploadWithMock
  , upload'
  , uploadHtmlImages
  , uploadImage
  ) where

import Proem

import Core.Exception.Index (EXCEPT_LOGIC)
import Core.Mod.Image.Image (Image(..))
import Core.Mod.MimeType as MimeType
import Core.Mod.Url.Url (Url)
import Run (Run, interpret, lift, on, send)
import Type.Row (type (+))

type AutocropBlackWhite = Boolean
type AutocropTransparent = Boolean

data Upload a
  = UploadImage AutocropBlackWhite AutocropTransparent Url (Image -> a)
  | UploadHtmlImages Boolean String (String -> a)

derive instance Functor Upload

type UPLOAD fx = (upload :: Upload | fx)

upload' = π :: Π "upload"

uploadImage :: ∀ fx. AutocropBlackWhite -> AutocropTransparent -> Url -> Run (UPLOAD + fx) Image
uploadImage autocropBlackWhite autocropTransparent url = lift upload' (UploadImage autocropBlackWhite autocropTransparent url identity)

uploadHtmlImages :: ∀ fx. Boolean -> String -> Run (UPLOAD + fx) String
uploadHtmlImages shouldRelativize content = lift upload' (UploadHtmlImages shouldRelativize content identity)

interpretUploadWithMock
  :: ∀ fx a
   . Run (UPLOAD + EXCEPT_LOGIC + fx) a
  -> Run (EXCEPT_LOGIC + fx) a
interpretUploadWithMock = interpret (on upload' handle send)
  where
  handle :: ∀ fx' a'. Upload a' -> Run (EXCEPT_LOGIC + fx') a'
  handle (UploadImage _ _ _ next) = do
    let
      img =
        Image
          { src: "path/to/a1b2c3d4e5f6g7h8.png"
          , hash: "a1b2c3d4e5f6g7h8"
          , mimeType: MimeType.ImagePng
          , size: 123_456
          , dimensions: { width: 800, height: 600 }
          }
    η $ next img
  handle (UploadHtmlImages _ content next) = do
    η $ next content
