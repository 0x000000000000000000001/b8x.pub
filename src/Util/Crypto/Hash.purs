module Util.Crypto.Hash where

import Proem

import Effect.Aff.Compat (EffectFnAff, fromEffectFnAff)
import Effect.Aff (Aff)

foreign import _md5 :: String -> String
foreign import _sha256 :: String -> String
foreign import _xxhash64 :: String -> EffectFnAff String

md5 :: String -> String
md5 = _md5

sha256 :: String -> String
sha256 = _sha256

xxhash64 :: String -> Aff String
xxhash64 str = _xxhash64 str # fromEffectFnAff

foreign import hmacSha256 :: String -> String -> String
