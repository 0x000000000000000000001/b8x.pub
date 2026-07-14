module Core.Mod.Image.Exception.Index where

import Core.Mod.Image.Exception.ImageCannotBeUploaded (ImageCannotBeUploaded)
import Core.Mod.Image.Exception.InvalidImage (InvalidImage)

type ImageExceptionRow r =
  ("Core.Mod.Image.Exception.InvalidImage" ∷ InvalidImage
  , "Core.Mod.Image.Exception.ImageCannotBeUploaded" ∷ ImageCannotBeUploaded
  | r
  )