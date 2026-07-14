module Util.Foreign.Native where

import Foreign (Foreign)
import Data.Either (Either(..))

foreign import parseJSONImpl :: (String -> Either String Foreign) -> (Foreign -> Either String Foreign) -> String -> Either String Foreign

parseJSON :: String -> Either String Foreign
parseJSON = parseJSONImpl Left Right
