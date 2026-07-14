module Util.File.Unzip where

import Proem

import Promise.Aff (Promise, toAffE)
import Data.ArrayBuffer.Types (ArrayBuffer)
import Data.Either (Either)
import Effect (Effect)
import Effect.Aff (Aff, attempt)
import Effect.Exception (Error)

foreign import _unzipGoogleSheetAndExtractHtml :: String -> ArrayBuffer -> Effect (Promise String)

foreign import _unzipToDirectory :: String -> ArrayBuffer -> Effect (Promise Ɩ)

unzipGoogleSheetAndExtractHtml :: String -> ArrayBuffer -> Aff (Either Error String)
unzipGoogleSheetAndExtractHtml htmlFilename zipContent =
  attempt $ toAffE $ _unzipGoogleSheetAndExtractHtml htmlFilename zipContent

unzipToDirectory :: String -> ArrayBuffer -> Aff (Either Error Ɩ)
unzipToDirectory outputDir zipContent =
  attempt $ toAffE $ _unzipToDirectory outputDir zipContent
