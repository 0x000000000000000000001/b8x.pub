module Util.Cookie.Cookie
  ( SerializeOptions
  , parse
  , serialize
  ) where

import Foreign.Object (Object)

foreign import parse :: String -> Object String

type SerializeOptions =
  { maxAge :: Int
  , httpOnly :: Boolean
  , path :: String
  , secure :: Boolean
  , sameSite :: String
  , domain :: String
  }

foreign import serializeImpl :: String -> String -> SerializeOptions -> String

serialize :: String -> String -> SerializeOptions -> String
serialize = serializeImpl
