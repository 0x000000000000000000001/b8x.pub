module Inter.Cli.CodeGen.Util
  (withHeader
  ) where

import Proem
import Data.String (Pattern(..), Replacement(..), replace)

withHeader :: String -> String -> String
withHeader moduleName content =
  let
    template =
      """-- 
-- Auto-generated.
-- Do not edit. Edit $filePath
--"""
  in
    ((template # replace (Pattern "$filePath") (Replacement moduleName))
        <> "\n"
        <> content
    )
