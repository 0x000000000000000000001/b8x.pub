module Core.Mod.User.Auth.Constant
  ( refreshTokenTtlSec
  ) where

-- | Time To Live (TTL) in seconds for the refresh token.
-- | 604800 seconds = 7 days.
refreshTokenTtlSec :: Int
refreshTokenTtlSec = 604800
