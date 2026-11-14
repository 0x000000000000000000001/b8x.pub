module Util.File.Docx where

import Proem

import Promise.Aff (Promise, toAffE)
import Data.ArrayBuffer.Types (ArrayBuffer)
import Data.Either (Either)
import Effect (Effect)
import Effect.Aff (Aff, attempt)
import Effect.Exception (Error)

foreign import _docxToHtml :: ArrayBuffer -> Effect (Promise String)

docxToHtml :: ArrayBuffer -> Aff (Either Error String)
docxToHtml arrayBuffer = attempt $ toAffE $ _docxToHtml arrayBuffer
