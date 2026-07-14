module Util.File.Image.Node where

import Proem

import Affjax.ResponseFormat (arrayBuffer)
import Data.Either (Either(..))
import Effect.Aff (Aff)
import Node.Buffer (fromArrayBuffer)
import Node.FS.Aff (writeFile)
import Util.Http.Http (getCheckStatus)

-- | Downloads an image from the given URL and saves it to the specified file path.
-- | Returns an error message if the download fails.
-- | Returns Right Ɩ on success, Left String on failure.
downloadImage :: String -> String -> Aff (Either String Ɩ)
downloadImage url filePath = do
  response <- getCheckStatus arrayBuffer url
  response
    ?!
      (\res -> do
          buffer <- ʌ $ fromArrayBuffer res.body
          writeFile filePath buffer
          Right ι # η
      )
    ⇿ (η ◁ Left)