module Util.Crypto.Paseto.Paseto
  ( encryptV3Local
  , decryptV3Local
  ) where

import Proem

import Foreign (Foreign)
import Effect.Aff (Aff)
import Effect.Aff.Compat (EffectFnAff, fromEffectFnAff)

foreign import encryptV3LocalImpl :: String -> Foreign -> String -> EffectFnAff String

foreign import decryptV3LocalImpl :: String -> String -> EffectFnAff Foreign

-- | Encrypts a payload using PASETO v3.local.
-- | The `key` must be a 64-character hex string (32 bytes).
-- | `expiresIn` is a string like "2h", "7d", etc.
encryptV3Local :: String -> Foreign -> String -> Aff String
encryptV3Local key payload expiresIn = encryptV3LocalImpl key payload expiresIn # fromEffectFnAff

-- | Decrypts a PASETO v3.local token.
-- | The `key` must be a 64-character hex string (32 bytes).
decryptV3Local :: String -> String -> Aff Foreign
decryptV3Local key token = decryptV3LocalImpl key token # fromEffectFnAff
