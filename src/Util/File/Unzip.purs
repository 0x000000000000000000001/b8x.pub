module Util.File.Unzip where

import Proem

import Effect.Aff.Compat (EffectFnAff, fromEffectFnAff)
import Data.ArrayBuffer.Types (ArrayBuffer)
import Data.Either (Either)
import Effect.Aff (Aff, attempt)
import Effect.Exception (Error)

foreign import _unzipGoogleSheetAndExtractHtml :: String -> ArrayBuffer -> EffectFnAff String

foreign import _unzipToDirectory :: String -> ArrayBuffer -> EffectFnAff Ɩ

unzipGoogleSheetAndExtractHtml :: String -> ArrayBuffer -> Aff (Either Error String)
unzipGoogleSheetAndExtractHtml htmlFilename zipContent =
  attempt $ fromEffectFnAff $ _unzipGoogleSheetAndExtractHtml htmlFilename zipContent

unzipToDirectory :: String -> ArrayBuffer -> Aff (Either Error Ɩ)
unzipToDirectory outputDir zipContent =
  attempt $ fromEffectFnAff $ _unzipToDirectory outputDir zipContent
