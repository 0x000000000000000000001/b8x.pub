module Util.Crypto.Hash where

import Promise.Aff (Promise, toAffE)
import Effect (Effect)
import Effect.Aff (Aff)

foreign import _md5 :: String -> String
foreign import _sha256 :: String -> String
foreign import _xxhash64 :: String -> Effect (Promise String)

md5 :: String -> String
md5 = _md5

sha256 :: String -> String
sha256 = _sha256

xxhash64 :: String -> Aff String
xxhash64 str = toAffE (_xxhash64 str)

foreign import hmacSha256 :: String -> String -> String
